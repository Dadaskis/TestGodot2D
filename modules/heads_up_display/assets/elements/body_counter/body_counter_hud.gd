extends Node

class_name BodyCounterHUD

@onready var amount = $Amount

func set_amount(value):
	amount.text = str(int(value))
