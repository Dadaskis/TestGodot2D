extends CharacterBody2D

## Folder containing all logic states
const LOGIC_STATES_PATH = "res://modules/enemy/src/states/"

## Maximum movement speed
@export var max_speed: = 300.0
## Movement acceleration
@export var acceleration: = 2000.0
## Movement friction
@export var friction: = 2000.0
## Air resistance when in air
@export var air_resistance: = 500.0
## Jump force
@export var jump_force: = 600.0
## Gravity force
@export var gravity: = 1200.0
## Maximum falling speed
@export var max_fall_speed: = 800.0
## Health 2D label above the enemy
@onready var health_label: = $Health
## Checks if there's any gap on the left
@onready var left_side_ray: = $LeftSideCheck
## Checks if there's any wall on the left
@onready var left_wall_ray: = $LeftWallCheck
## Checks if there's any gap on the right
@onready var right_side_ray: = $RightSideCheck
## Checks if there's any wall on the right
@onready var right_wall_ray: = $RightWallCheck
## Checks if there's any other character near-by
@onready var vision_area: = $Vision
## Checks if other character has left the vision field
@onready var far_vision_area: = $FarVision
## Spear animations
@onready var attack_anim_player: = $AttackPlayer
## Damage/Death animations
@onready var damage_anim_player: = $DamagePlayer
## Collision shape to remove on death
@onready var collision: = $Collision

## Jump buffer
var jump_buffer_timer: = 0.0
## Was the controller on floor?
var was_on_floor: = false
## Is jumping now?
var is_jumping: = false
## Does it need to jump?
var needs_to_jump = false
## Walking direction
var direction: = 0.0
## Dictionary of all visible characters
var visible_chars = {}
## Character data
var character: Character
## State machine for AI
var state_machine: FiniteStateMachine
## Concussion timer, disables logic after getting pushed
var push_timer = 0.0

## Initializing the character [br]
## 1. Preparing character data [br]
## 2. Connecting signals [br]
## 3. Preparing the state machine
func _ready():
	character = Character.new()
	HitBodyTool.add_node_property(self, Character.OBJECT_NAME, character)
	CharacterTools.init_damageable(character, self)
	character.on_damage.connect(on_damage)
	character.on_death.connect(on_death)
	character.on_push.connect(on_push)
	
	vision_area.body_entered.connect(on_vision_body_entered)
	far_vision_area.body_exited.connect(on_vision_body_exited)
	
	visible_chars = {}
	state_machine = FiniteStateMachine.new()
	state_machine.character = character
	state_machine.load_all_states_from_dir(LOGIC_STATES_PATH)
	state_machine.switch_state("patrol")
	state_machine.set_property("visible_chars", visible_chars)

## Processing movement, attacks, push timers, etc
func _physics_process(delta: float) -> void:
	push_timer -= delta
	character.set_raycast_point(global_position)
	
	if not character.is_alive() or push_timer > 0.0:
		return
	
	state_machine.update(delta)
	
	# Get input direction
	direction = state_machine.get_property("direction")
	
	# Handle attacks
	handle_attack()
	
	# Handle horizontal movement
	handle_movement(delta)
	
	# Handle jumping and gravity
	handle_jumping(delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	
	# Move the character
	move_and_slide()
	
	# Check if we just left the ground (for coyote time)
	was_on_floor = is_on_floor()

## Handles attacks upon need of the state machine
func handle_attack():
	if not state_machine.get_property("attack_required"):
		return
	
	if attack_anim_player.is_playing():
		return
	
	state_machine.set_property("attack_required", false)
	
	if direction < 0.0:
		attack_anim_player.play("attack_left")
	else:
		attack_anim_player.play("attack_right")

## Checks all characters that entered the view
func on_vision_body_entered(body: Object):
	var character = HitBodyTool.get_node_property(body, Character.OBJECT_NAME)
	if character and (character != self.character):
		var key = body.get_instance_id()
		visible_chars[key] = character

## Forgers all characters that exited the far view
func on_vision_body_exited(body: Object):
	var character = HitBodyTool.get_node_property(body, Character.OBJECT_NAME)
	if character and (character != self.character):
		var key = body.get_instance_id()
		visible_chars.erase(key)

## Enables push timer after getting pushed, as well as applies velocity
func on_push(vel: Vector2):
	velocity = vel
	push_timer = 0.3

## Updates the health label and plays the damage animation
func on_damage(value: float):
	health_label.text = str(int(character.health))
	damage_anim_player.play("damage")

## Removes collision on death, plays animations, removes itself afterwards
func on_death():
	collision.queue_free()
	damage_anim_player.play("death")
	await damage_anim_player.animation_finished
	queue_free()

## Checks if it is possible to go further [br]
## 1. Checks the gaps [br]
## 2. Checks the walls [br]
## If none - character can go further
func check_possibility_to_go() -> void:
	var can_go_further = true
	if direction < 0.0:
		can_go_further = \
			left_side_ray.is_colliding() and not left_wall_ray.is_colliding()
		if not can_go_further:
			state_machine.set_property(
				"patrol_dir", not state_machine.get_property("patrol_dir")
			)
	if direction > 0.0:
		can_go_further = \
			right_side_ray.is_colliding() and not right_wall_ray.is_colliding()
		if not can_go_further:
			state_machine.set_property(
				"patrol_dir", not state_machine.get_property("patrol_dir")
			)
	if not can_go_further:
		direction = 0.0

## Handles movement depending on parameters of the state machine
func handle_movement(delta: float) -> void:
	check_possibility_to_go()
	
	if direction != 0:
		# Accelerate in the direction of input
		var target_speed = direction * max_speed
		target_speed *= state_machine.get_property("speed_mult")
		var acceleration_to_use = acceleration
		if not is_on_floor():
			acceleration_to_use = air_resistance
		velocity.x = move_toward(
			velocity.x, target_speed, acceleration_to_use * delta)
	else:
		# Apply friction when no input
		var resistance_to_use = friction
		if not is_on_floor():
			resistance_to_use = air_resistance
		velocity.x = move_toward(velocity.x, 0, resistance_to_use * delta)

## Handles jumping
func handle_jumping(delta: float) -> void:
	# Jump if pressed and either on floor or in coyote time
	if can_jump():
		velocity.y = -jump_force
		is_jumping = true
		jump_buffer_timer = 0.0
	
	# Cancel jump if hitting ceiling
	if is_on_ceiling():
		is_jumping = false
		velocity.y = 0
	
	# Reset jump state when on ground
	if is_on_floor():
		is_jumping = false

## Can this character jump? [br]
## Checks if on floor and if state machine asks to jump
func can_jump() -> bool:
	return is_on_floor() and needs_to_jump
