# Base class for all damageable objects in the game
# Provides core damage handling functionality and type definitions
# All objects that can take damage should inherit from this class
class_name Damageable

extends HitBodyProperty

# Identifier for this type of object
const OBJECT_NAME = "Damageable"

# Enum defining all possible damage types in the game
enum DamageType {
	GENERIC,     # Default/unspecified damage
	BULLET,      # Firearm/projectile damage
	FALL,        # Fall impact damage  
	MELEE,       # Close combat damage
	EXPLOSION,   # Explosive damage
	BIOBOMB,     # Biological weapon damage
	ELECTRICITY, # Electrical damage
	PUNCH,       # Fist/hand-to-hand damage
	GAS,         # Toxic gas damage
	LOW_AIR,     # Suffocation damage
	RADIATION,   # Radiation damage
	CHEMICALS,   # Chemical damage
	PROP,        # Physics object/prop damage
	NONE         # No damage (placeholder)
}

# Emitted when object receives damage (before health is reduced)
signal on_damage(value)

# Checks if object can currently receive damage
# Returns: Boolean indicating if damage can be applied
func can_take_damage():
	# Currently serves as a placeholder for future use
	return true

# Initialization hook for derived classes
func initialize():
	pass

# Main initialization called when object enters scene
func on_init():
	# Call derived class initialization
	initialize()

# Base damage handling method - should be overridden by derived classes
# value: Amount of damage to apply
# damage_type: Type of damage (from DamageType enum)
# position: World position where damage originated (Vector3)
# direction: Direction vector of damage source (Vector3)
# author: Optional reference to damage source object
func damage(value: float, 
		damage_type: = DamageType.GENERIC,
		position: = Vector2.ZERO,
		direction: = Vector2.ZERO,
		author = null) -> void:
	# Emit signal by default - derived classes should add actual damage logic
	emit_signal("on_damage", value)
