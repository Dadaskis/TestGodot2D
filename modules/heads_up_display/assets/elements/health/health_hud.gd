class_name HealthHUD

extends Node

@onready var amount: = $Amount

func set_amount(value):
	amount.text = str(int(value))
