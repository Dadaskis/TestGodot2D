## Character object for any character in this game. [br]
## Contains plenty of useful info to use in AI logic calculations. [br]
## It is a hit body property, meaning of which you can detect the character with ray, [br]
## if you use some trickery like... [br]
## [br]
## [gd] [br]
## var ray = space_state.intersect_ray(start, end) [br]
## var body = ray.collider [br]
## var character = HitBodyTool.get_node_property(body, Character.OBJECT_NAME) [br]
## [/gd] [br]

extends HitBodyProperty

class_name Character

## "Object name" to refer to with HitBodyTool. Unique name of this component.
const OBJECT_NAME = "Character"

## Character's current health.
var health: = 100.0: set = set_health
## Character's maximum health.
var max_health: = 100.0: set = set_max_health
## Is this character alive?
var alive: = true 
## Characters "raycast point", usually refers to head of any character.
## Proper positioning of this value is crucial for good visibility checks.
var raycast_point: Vector2: set = set_raycast_point
## Last damage hit position.
var last_damage_position: Vector2
## Last damage hit direction.
var last_damage_direction: Vector2
## Last damage type.
var last_damage_type: int
## Last damage health amount.
var last_damage_amount: float
## Last damage author.
var last_damage_author: Character
## What's the node is controlling this character?
var control_node
## Meta data for any cases
var meta_data = {}

## Emits signal on death of this character
signal on_death()
## Emits signal on any damage that is applied on this character [br]
## value - Amount of damage
signal on_damage(value)
## Emits signal on change of armor values of this character [br]
## value - Current amount of armor [br]
## difference - Difference of current and previous values. Always a positive number.
signal on_armor_change(value, difference)
## Emitted when this character is getting pushed [br]
## velocity - Direction to which character should be pushed
signal on_push(velocity)

## Restore this character's health by setting it on maximum health
func restore_health():
	health = max_health

## Add self to character list on initialization
func on_init():
	CharacterList.add_character(self)

## Apply damage on this character. [br]
## value - Amount of damage. [br]
## damage_position - Damage hit global position. [br]
## damage_direction - Damage hit global direction. [br]
## damage_type - Damage type. [br]
## damage_author - Damage author (reference to another character)
func damage(
	value: float, 
	damage_position: = Vector2.ZERO,
	damage_direction: = Vector2.ZERO,
	damage_type: int = Damageable.DamageType.GENERIC,
	damage_author: Character = null
) -> void:
	if not alive:
		return
	if value <= 0.0:
		return
	last_damage_position = damage_position
	last_damage_direction = damage_direction
	last_damage_type = damage_type
	last_damage_amount = value
	last_damage_author = damage_author
	emit_signal("on_damage", value)
	add_health(-value)

## Add health to this character
func add_health(health: float) -> void:
	self.health += health
	if self.health >= max_health:
		self.health = max_health
	elif self.health <= 0.0:
		self.health = 0.0
		if alive:
			alive = false
			emit_signal("on_death")
			CharacterList.remove_character(self)

## Set health of this character
func set_health(value: float) -> void:
	if is_nan(value):
		value = 100
	value = clamp(value, 0, 10000000)
	health = value
	if health >= max_health:
		health = max_health

## Returns health of this character
func get_health() -> float:
	return health

## Set maximum health of this character
func set_max_health(value: float) -> void:
	max_health = value

## Returns maximum health of this character
func get_max_health() -> float:
	return max_health

## Set raycast point position.
## That is a global position so you may need to update it as frequently,
## as it is possible (each frame?)
func set_raycast_point(point: Vector2) -> void:
	if point != point:
		raycast_point = Vector2.ZERO
		return
	raycast_point = point

## Returns this character's raycast point global position.
func get_raycast_point() -> Vector2:
	return raycast_point

## Is this character alive?
func is_alive() -> bool:
	return alive

## Makes this character alive and sets health to maximum.
func make_alive() -> void:
	alive = true
	CharacterList.add_character(self)
	set_health(max_health)

## Pushes the character with specified velocity
func push(velocity: Vector2) -> void:
	on_push.emit(velocity)

## Set meta data value for this character
func set_meta_data(key: String, value):
	meta_data[key] = value

## Get meta data value of this character
func get_meta_data(key: String, default_value = null):
	return meta_data.get(key, default_value)
