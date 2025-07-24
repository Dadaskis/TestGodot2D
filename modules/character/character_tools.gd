extends Node

## Initialize Damageable on certain node.
## Damageable will automatically refer to this character and apply damage as it follows.
func init_damageable(character: Character, node: Node) -> void:
	var character_damage = CharacterDamagable.new()
	character_damage.character = character
	HitBodyTool.add_node_property(
		node, CharacterDamagable.OBJECT_NAME, character_damage)
