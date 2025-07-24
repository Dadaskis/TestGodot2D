# Damagable object for characters. Has methods to work with
# character as well as reference to original author and damage multiplier.

class_name CharacterDamagable

extends Damageable

# Reference to character that this damagable belongs to.
var character: Character

# Overall damage multiplier. Useful for various hitbox multipliers.
var damage_multiplier: = 1.0

# Damage health of this character. Doesn't take any damage if "can_take_damage()" returns false.
# value - Amount of damage.
# damage_type - Damage type.
# position - Damage hit global position.
# direction - Damage hit global direction.
# author - Damage author (reference to another character)
func damage(
	value: float, 
	damage_type: = Damageable.DamageType.GENERIC,
	position: = Vector2.ZERO,
	direction: = Vector2.ZERO,
	author: Character = null
) -> void:
	if not can_take_damage():
		return
	
	character.damage(
		value * damage_multiplier, 
		position, 
		direction, 
		damage_type, 
		author
	)
