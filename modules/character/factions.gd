# __AUTOLOAD
# Globally accessible class of character faction relationships.
# Factions are used in this game to specify relationships between groups of NPCs
# instead of making them check relationships individually.
# If you want to make totally unique character with unique relationships,
# you'll have to make a unique faction for that.
# Otherwise, like in most cases of this game, you'll just have to specify relationships
# between limited list of "factions". 
# Like "player", "minc", "scavenger", "police", "citizen", etc.

extends Node

# Types of relationships that can be used in character's AI.
# At this moment, only "Neutral" and "Enemy" are used in calculations.
# Other values are preserved for potential future use.
enum RelationshipType {
	NEUTRAL,
	FEAR,
	ENEMY,
	FRIEND
}

# A dictionary that stores all faction's relationships.
# relationships[faction0][faction1] == relationship_type
# Dictionary in dictionaries.
var relationships = {}

# Resets relationships dictionary.
func reset():
	relationships = {}

# Verifies dictionary for [faction0] faction.
func verify_dict(faction0: String) -> void:
	if relationships.get(faction0) == null:
		relationships[faction0] = {}

# Sets faction relationship between [faction0] and [faction1] to
# [relationship_type] RelationshipType enum.
func set_faction_relationship(
		faction0: String, 
		faction1: String, 
		relationship_type: int
	) -> void:
	verify_dict(faction0)
	verify_dict(faction1)
	relationships[faction0][faction1] = relationship_type
	relationships[faction1][faction0] = relationship_type

# Returns RelationshipType that represents relationship between
# [faction0] and [faction1]
func get_faction_relationship(faction0: String, faction1: String) -> int:
	var dict = relationships.get(faction0)
	if dict == null:
		return RelationshipType.NEUTRAL
	
	var relationship = dict.get(faction1)
	
	if relationship != null:
		return relationship
	
	return RelationshipType.NEUTRAL

# Returns a list of all currently available factions.
func get_faction_list() -> Array:
	return relationships.keys()
