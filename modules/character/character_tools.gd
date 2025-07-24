extends Node

const DMG_SCRIPT = preload(
	"res://modules/character/character_damageable.gd"
)

# Initialize Damageable on certain node.
# Damageable will automatically refer to this character and apply damage as it follows.
func init_damageable(character: Character, node: Node) -> void:
	var character_damage = DMG_SCRIPT.new()
	character_damage.character = character
	HitBodyTool.add_node_property(
		node, DMG_SCRIPT.OBJECT_NAME, character_damage)
