## Game Over HUD - Shows up when player dies

extends Node

class_name GameOverHUD

## Reference to restarting label
@onready var restarting: = $Restarting
## Timer before switch
var timer = 5.5

## Emitted when restarting is required
signal on_finish()

## Runs the timer and changes text
func _physics_process(delta: float) -> void:
	if timer <= 0.0:
		return
	timer -= delta
	restarting.text = "Restarting in {0}...".format([int(timer)])
	if timer <= 0.0:
		on_finish.emit()
