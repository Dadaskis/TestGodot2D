extends Area2D

var damageables = []
var timer = 0.0

func on_area_enter(body: Object):
	var dmg = HitBodyTool.get_node_property(body, Damageable.OBJECT_NAME)
	if dmg:
		damageables.append(dmg)

func on_area_exit(body: Object):
	var dmg = HitBodyTool.get_node_property(body, Damageable.OBJECT_NAME)
	if dmg:
		damageables.erase(dmg)

func _physics_process(delta: float) -> void:
	timer += delta
	if timer < 0.5:
		return
	timer = 0.0
	
	for dmg in damageables:
		dmg.damage(10.0)

func _ready():
	connect("body_entered", on_area_enter)
	connect("body_exited", on_area_exit)
