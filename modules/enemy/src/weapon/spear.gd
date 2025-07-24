## Enemies spear script

extends Area2D

## Damage anything that is entering the Area2D
func on_area_enter(body: Object):
	if body == get_parent():
		return
	var dmg = HitBodyTool.get_node_property(body, Damageable.OBJECT_NAME)
	if dmg:
		dmg.damage(15.0)
	var char = HitBodyTool.get_node_property(body, Character.OBJECT_NAME)
	if char:
		var push_dir = global_position.direction_to(char.raycast_point)
		char.push(push_dir * 200.0)

## Connects a signal
func _ready():
	body_entered.connect(on_area_enter)
