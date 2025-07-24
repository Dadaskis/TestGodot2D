extends CharacterBody2D

# Movement parameters
@export var max_speed: = 300.0
@export var acceleration: = 2000.0
@export var friction: = 2000.0
@export var air_resistance: = 500.0

# Jump parameters
@export var jump_force: = 600.0
@export var gravity: = 1200.0
@export var max_fall_speed: = 800.0
# Reduce jump height when releasing jump early
@export var variable_jump_reduction: = 0.5

# Player feel improvements
# Time after leaving ledge when you can still jump
@export var coyote_time: = 0.1
# Time before landing when jump input is remembered
@export var jump_buffer_time: = 0.1

@onready var health_label: = $Health
@onready var camera: = $Camera

# Internal variables
var coyote_timer: = 0.0
var jump_buffer_timer: = 0.0
var was_on_floor: = false
var is_jumping: = false
var direction: = 0.0
var character: Character
var health_HUD: HealthHUD

func _ready():
	character = Character.new()
	HitBodyTool.add_node_property(self, Character.OBJECT_NAME, character)
	CharacterTools.init_damageable(character, self)
	character.on_damage.connect(on_damage)
	character.on_death.connect(on_death)
	
	health_HUD = HeadsUpDisplay.add_element("health")
	health_HUD.set_amount(character.health)

func _physics_process(delta: float) -> void:
	if not character.is_alive():
		velocity = Vector2(0.0, 10.0)
		move_and_slide()
		return
	
	# Get input direction
	direction = Input.get_axis("move_left", "move_right")
	
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
	
	# Move the character
	move_and_slide()
	
	# Check if we just left the ground (for coyote time)
	was_on_floor = is_on_floor()

func update_camera(delta):
	camera.global_position = lerp(
		camera.global_position,
		global_position,
		3.0 * delta
	)

func on_damage(value: float):
	print("Taking damage: " + str(value))
	health_label.text = str(int(character.health))
	health_HUD.set_amount(character.health)

func on_death():
	print("Death!")

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

func can_jump() -> bool:
	# Check if jump was pressed recently (jump buffering)
	return Input.is_action_just_pressed("jump") or jump_buffer_timer > 0

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
