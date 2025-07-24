extends CharacterBody2D

const LOGIC_STATES_PATH = "res://modules/enemy/src/states/"

# Movement parameters
@export var max_speed: = 300.0
@export var acceleration: = 2000.0
@export var friction: = 2000.0
@export var air_resistance: = 500.0

# Jump parameters
@export var jump_force: = 600.0
@export var gravity: = 1200.0
@export var max_fall_speed: = 800.0

@onready var health_label: = $Health
@onready var left_side_ray: = $LeftSideCheck
@onready var left_wall_ray: = $LeftWallCheck
@onready var right_side_ray: = $RightSideCheck
@onready var right_wall_ray: = $RightWallCheck

# Internal variables
var jump_buffer_timer: = 0.0
var was_on_floor: = false
var is_jumping: = false
var needs_to_jump = false
var direction: = 0.0
var character: Character
var state_machine: FiniteStateMachine

func _ready():
	character = Character.new()
	HitBodyTool.add_node_property(self, Character.OBJECT_NAME, character)
	CharacterTools.init_damageable(character, self)
	character.on_damage.connect(on_damage)
	character.on_death.connect(on_death)
	character.on_push.connect(on_push)
	
	state_machine = FiniteStateMachine.new()
	state_machine.load_all_states_from_dir(LOGIC_STATES_PATH)
	state_machine.switch_state("patrol")

func _physics_process(delta: float) -> void:
	if not character.is_alive():
		velocity = Vector2(0.0, 10.0)
		move_and_slide()
		return
	
	state_machine.update(delta)
	
	# Get input direction
	direction = state_machine.get_property("direction")
	
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

func on_push(vel: Vector2):
	velocity = vel * 2.0

func on_damage(value: float):
	health_label.text = str(int(character.health))

func on_death():
	pass

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

func can_jump() -> bool:
	return is_on_floor() and needs_to_jump
