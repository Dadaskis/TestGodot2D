extends State

var direction = 1.0

func on_switch():
	set_property("speed_mult", 0.2)

func on_update(delta: float):
	if get_property("patrol_dir"):
		direction = 1.0
	else:
		direction = -1.0
	set_property("direction", direction)
