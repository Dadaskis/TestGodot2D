## __AUTOLOAD [br]
## Singleton manager for hit body properties in the game [br]
## Maintains registry of all interactive objects and their collision properties [br]
## [br]
## [Use examples] [br]
## [br]
## Getting a hit body property: [br]
## [gd] [br]
## var usable = HitBodyTool.get_node_property(body, Usable.OBJECT_NAME) [br]
## if usable: [br]
## # ... [br]
## [/gd] [br]
## [br]
## Setting a hit body property: [br]
## [gd] [br]
## # Keep in mind, node property can be assigned to any object. [br]
## # But usually it makes sense to assign it to a physics body [br]
## # like StaticBody, RigidBody, etc. [br]
## # Because you can get it in later physics checks like raycasts. [br]
## HitBodyTool.add_node_property(body, Usable.OBJECT_NAME, usable) [br]
## [/gd]

extends Node

## Dictionary storing all hit bodies keyed by instance ID
var hit_bodies = {}

## Adds a new property to a node's hit body [br]
## node: The target node to receive the property [br]
## hit_name: String identifier for the property type [br]
## value: HitBodyProperty instance to add
func add_node_property(node, hit_name: String, value):
	if not value:
		push_error("Value is null")
		return
	
	if not is_instance_valid(node):
		push_error("Node is not valid")
		return
	
	# Get existing hit body or create new one
	var hit_body = hit_bodies.get(node.get_instance_id(), null)
	if not hit_body:
		hit_body = HitBody.new()
		hit_body.node = node
		hit_bodies[node.get_instance_id()] = hit_body
	
	# Add the specified property
	hit_body.add_hit_property(hit_name, value)

## Retrieves a property from a node's hit body [br]
## node: The node to query [br]
## hit_name: String identifier of the property to retrieve [br]
## Returns: The HitBodyProperty or null if not found
func get_node_property(node: Object, hit_name: String):
	var hit_body = hit_bodies.get(node.get_instance_id(), null)
	if not hit_body:
		return null
	return hit_body.get_hit_property(hit_name)

## Cleans up invalid/destroyed hit body references
func validate_hit_bodies():
	for hit_body_key in hit_bodies.keys():
		var hit_body = hit_bodies[hit_body_key]
		# Remove entries for deleted nodes
		if not is_instance_valid(hit_body.node):
			hit_bodies.erase(hit_body_key)
