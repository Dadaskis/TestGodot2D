class_name State

var properties = {}
var character: Character

signal switch_state(state_name)

func on_register():
	pass

func on_switch():
	pass

func on_before_switch():
	pass

func on_update(delta):
	pass

func switch():
	on_switch()

func before_switch():
	on_before_switch()

func update(delta: float):
	on_update(delta)

func set_property(key, value):
	properties[key] = value

func get_property(key):
	return properties.get(key)
