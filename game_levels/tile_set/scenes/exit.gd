extends Area2D

var is_activated = false

func on_area_enter(body: Object):
	if is_activated:
		return
	var char = HitBodyTool.get_node_property(body, Character.OBJECT_NAME)
	if char:
		if char.get_meta_data("is_player"):
			is_activated = true
			HeadsUpDisplay.reset()
			var game_win_hud = \
				HeadsUpDisplay.add_element("game_win") as GameWinHUD
			await game_win_hud.on_finish
			get_tree().reload_current_scene()

func _ready():
	$Floating.play("floating")
	body_entered.connect(on_area_enter)
