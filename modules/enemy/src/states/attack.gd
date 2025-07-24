## Simple attack state

extends State

## Set full speed on switch
func on_switch():
	set_property("speed_mult", 1.0)

## Finds the last visible characters and approaches it to attack
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
	
	var dist = pos0.distance_squared_to(pos1)
	if dist < 23000.0:
		set_property("attack_required", true)
