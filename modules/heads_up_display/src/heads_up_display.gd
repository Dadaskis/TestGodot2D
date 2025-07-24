extends CanvasLayer

const ELEMENTS_PATH = "res://modules/heads_up_display/assets/elements/"

var elements = []

func add_element(element_name: String):
	var node = get_node_or_null(element_name)
	if is_instance_valid(node):
		return node
	var path = ELEMENTS_PATH + element_name + "/element.scn"
	if not ResourceLoader.exists(path):
		return null
	var scene: = load(path) as PackedScene
	var element = scene.instantiate()
	element.name = element_name
	add_child(element)
	elements.append(element)
	return element

func remove_element(element_name: String):
	var node = get_node_or_null(element_name)
	if is_instance_valid(node):
		node.queue_free()

func reset():
	for child in get_children():
		child.name = "__REMOVED"
		child.queue_free()
	elements = []
