## Health HUD - Shows player health

class_name HealthHUD

extends Node

## Reference to amount label
@onready var amount: = $Amount

## Changes amount label text
func set_amount(value):
	amount.text = str(int(value))
