extends Node

class_name GameWinHUD

@onready var restarting: = $Restarting
var timer = 5.5

signal on_finish()

func _physics_process(delta: float) -> void:
	if timer <= 0.0:
		return
	timer -= delta
	restarting.text = "Restarting in {0}...".format([int(timer)])
	if timer <= 0.0:
		on_finish.emit()
