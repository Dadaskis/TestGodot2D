## Patrol state

extends State

## Direction to go to
var direction = 1.0

## On switch - set slower walking speed
func on_switch():
	set_property("speed_mult", 0.2)

## Walk around, if there's an enemy - switch to attacking
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
