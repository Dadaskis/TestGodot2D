extends Area2D

signal kill_confirmed()

func on_area_enter(body: Object):
	if body == get_parent():
		return
	var dmg = HitBodyTool.get_node_property(body, Damageable.OBJECT_NAME)
	if dmg:
		dmg.damage(30.0)
	var char = HitBodyTool.get_node_property(body, Character.OBJECT_NAME)
	if char:
		var push_dir = global_position.direction_to(char.raycast_point)
		char.push(push_dir * 800.0)
		if not char.is_alive():
			kill_confirmed.emit()

func _ready():
	body_entered.connect(on_area_enter)
