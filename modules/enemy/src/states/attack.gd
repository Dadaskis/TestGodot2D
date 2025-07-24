extends State

func on_switch():
	set_property("speed_mult", 1.0)

func on_update(delta: float):
	var chars = get_property("visible_chars")
	var chars_array = chars.values()
	if len(chars_array) == 0:
		switch_state.emit("patrol")
		return
	var enemy = chars_array[-1]
	var pos0 = character.raycast_point
	var pos1 = enemy.raycast_point
	if pos0.x < pos1.x:
		set_property("direction", 1.0)
	else:
		set_property("direction", -1.0)
