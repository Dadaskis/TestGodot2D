## Game Win HUD - Shows up when player exits the game level

extends Node

class_name GameWinHUD

## Reference to restarting label
@onready var restarting: = $Restarting
## Timer before restart
var timer = 5.5

## Emitted when restart is required
signal on_finish()

## Runs the timer, changes text, emits signal
func _physics_process(delta: float) -> void:
	if timer <= 0.0:
		return
	timer -= delta
	restarting.text = "Restarting in {0}...".format([int(timer)])
	if timer <= 0.0:
		on_finish.emit()
