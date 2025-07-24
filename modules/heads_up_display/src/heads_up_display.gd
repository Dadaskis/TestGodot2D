## Heads Up Display singleton that is handling multiple elements

extends CanvasLayer

## Path to folders of individual HUD elements
const ELEMENTS_PATH = "res://modules/heads_up_display/assets/elements/"

## Array of added HUD elements
var elements = []

## Adds a HUD elements and returns it
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

## Removes a HUD element by name
func remove_element(element_name: String):
	var node = get_node_or_null(element_name)
	if is_instance_valid(node):
		node.queue_free()

## Resets HUD by removing all children from scene tree
func reset():
	for child in get_children():
		remove_child(child)
	elements = []
