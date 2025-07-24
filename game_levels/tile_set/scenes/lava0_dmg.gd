## Lava that damages anything that can be damaged

extends Area2D

## A list of all damageable objects that entered the trigger
var damageables = []
## General-purpose timer
var timer = 0.0

## Adds all damageable bodies into array
func on_area_enter(body: Object):
	var dmg = HitBodyTool.get_node_property(body, Damageable.OBJECT_NAME)
	if dmg:
		damageables.append(dmg)

## Removes the exited body from the array
func on_area_exit(body: Object):
	var dmg = HitBodyTool.get_node_property(body, Damageable.OBJECT_NAME)
	if dmg:
		damageables.erase(dmg)

## Deals 10.0 damage every 0.5 seconds
func _physics_process(delta: float) -> void:
	timer += delta
	if timer < 0.5:
		return
	timer = 0.0
	
	for dmg in damageables:
		dmg.damage(10.0)

## Simply connects some signals
func _ready():
	body_entered.connect(on_area_enter)
	body_exited.connect(on_area_exit)
