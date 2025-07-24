extends CharacterBody2D

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
## Reduce jump height when releasing jump early
@export var variable_jump_reduction: = 0.5
## Time after leaving ledge when you can still jump
@export var coyote_time: = 0.1
## Time before landing when jump input is remembered
@export var jump_buffer_time: = 0.1
## Health label
@onready var health_label: = $Health
## The player's camera
@onready var camera: = $Camera
## Animations for sword attacks
@onready var attack_anim_player: = $AttackPlayer
## Damage/Death animations
@onready var damage_anim_player: = $DamagePlayer
## Player's sword that is required for body count
@onready var sword: = $Sword
## Collision to remove on death
@onready var collision: = $Collision

# Internal variables

## Coyote timer
var coyote_timer: = 0.0
## Jump buffer timer
var jump_buffer_timer: = 0.0
## Was the controller on floor during previous frame?
var was_on_floor: = false
## Is jumping?
var is_jumping: = false
## Direction to go to
var direction: = 0.0
## Character data
var character: Character
## Health HUD
var health_HUD: HealthHUD
## Body counter HUD
var body_counter_HUD: BodyCounterHUD
## Amount of killed characters
var body_count = 0

## Initializes the player [br]
## 1. Initalizes character data [br]
## 2. Initializes HUD [br]
## 3. Connects some signals here and there
func _ready():
	character = Character.new()
	HitBodyTool.add_node_property(self, Character.OBJECT_NAME, character)
	CharacterTools.init_damageable(character, self)
	character.on_damage.connect(on_damage)
	character.on_death.connect(on_death)
	character.set_meta_data("is_player", true)
	
	HeadsUpDisplay.reset()
	
	health_HUD = HeadsUpDisplay.add_element("health")
	health_HUD.set_amount(character.health)
	
	body_counter_HUD = HeadsUpDisplay.add_element("body_counter")
	
	sword.kill_confirmed.connect(add_body)

## Updates movement logic depending on inputs, handles attacks
func _physics_process(delta: float) -> void:
	character.set_raycast_point(global_position)
	
	if not character.is_alive():
		return
	
	# Get input direction
	direction = Input.get_axis("move_left", "move_right")
	
	# Handle attack inputs
	handle_attack()
	
	# Handle horizontal movement
	handle_movement(delta)
	
	# Handle jumping and gravity
	handle_jumping(delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	
	# Update coyote time and jump buffer timers
	update_timers(delta)
	
	# Updates camera position smoothly
	update_camera(delta)
	
	# Pushing others
	check_characters_to_push()
	
	# Move the character
	move_and_slide()
	
	# Check if we just left the ground (for coyote time)
	was_on_floor = is_on_floor()

## Adds one more killed character
func add_body():
	body_count += 1
	body_counter_HUD.set_amount(body_count)

## Checks inputs for attacks and plays animation if there's input
func handle_attack():
	if not Input.is_action_just_pressed("attack"):
		return
	
	if attack_anim_player.is_playing():
		return
	
	if direction < 0.0:
		attack_anim_player.play("attack_left")
	else:
		attack_anim_player.play("attack_right")

## Checks all collisions and pushes characters if possible
func check_characters_to_push():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if not collider:
			continue
		var character = \
			HitBodyTool.get_node_property(collider, Character.OBJECT_NAME)
		if character:
			character.push(velocity * 2.0)

## Smoothly updates camera position
func update_camera(delta):
	camera.global_position = lerp(
		camera.global_position,
		global_position,
		3.0 * delta
	)

## Called on taken damage
func on_damage(value: float):
	print("Taking damage: " + str(value))
	health_label.text = str(int(character.health))
	health_HUD.set_amount(character.health)
	damage_anim_player.play("damage")

## Called when the player is dying
func on_death():
	print("Death!")
	collision.queue_free()
	damage_anim_player.play("death")
	HeadsUpDisplay.reset()
	var game_over_hud = HeadsUpDisplay.add_element("game_over") as GameOverHUD
	await game_over_hud.on_finish
	get_tree().reload_current_scene()

## Handles movement based on `direction` variable
func handle_movement(delta: float) -> void:
	if direction != 0:
		# Accelerate in the direction of input
		var target_speed = direction * max_speed
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

## Handles jumping based on inputs
func handle_jumping(delta: float) -> void:
	# Jump if pressed and either on floor or in coyote time
	if can_jump() and (is_on_floor() or coyote_timer > 0):
		velocity.y = -jump_force
		is_jumping = true
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
	
	# Variable jump height - jump higher if holding jump button
	if is_jumping and Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= variable_jump_reduction
		is_jumping = false
	
	# Cancel jump if hitting ceiling
	if is_on_ceiling():
		is_jumping = false
		velocity.y = 0
	
	# Reset jump state when on ground
	if is_on_floor():
		is_jumping = false

## Returns boolean depending on possibility of jumping
func can_jump() -> bool:
	# Check if jump was pressed recently (jump buffering)
	return Input.is_action_just_pressed("jump") or jump_buffer_timer > 0

## Update timers related to jumping
func update_timers(delta: float) -> void:
	# Update coyote timer (time after leaving ledge when you can still jump)
	if was_on_floor and not is_on_floor():
		coyote_timer = coyote_time
	elif coyote_timer > 0:
		coyote_timer -= delta
	
	# Update jump buffer timer (remember jump input before landing)
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	elif jump_buffer_timer > 0:
		jump_buffer_timer -= delta
