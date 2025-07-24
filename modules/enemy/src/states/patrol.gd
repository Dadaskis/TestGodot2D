extends State

var direction = 1.0

func on_switch():
	set_property("speed_mult", 0.2)

func on_update(delta: float):
	var chars = get_property("visible_chars")
	if len(chars.values()) > 0:
		switch_state.emit("attack")
		return
	
	if get_property("patrol_dir"):
		direction = 1.0
	else:
		direction = -1.0
	set_property("direction", direction)
