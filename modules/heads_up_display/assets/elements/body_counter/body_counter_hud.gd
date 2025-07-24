## Body Counter HUD - How many enemies have been killed?

extends Node

class_name BodyCounterHUD

## Reference to amount label
@onready var amount = $Amount

## Sets amount label text
func set_amount(value):
	amount.text = str(int(value))
