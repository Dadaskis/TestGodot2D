## Base class for all hit interaction properties [br]
## Provides common interface for making a HitBody property to get in later [br]
## raycast checks

class_name HitBodyProperty

## Name identifier for this property
var name: String

## Reference to the node with this property
var owner: Node

## Reference to the immediate parent node
var parent: Node

## Returns the parent node reference
func get_parent():
	return parent

## Returns the owner node reference
func get_owner():
	return owner

## Returns the property name
func get_name():
	return name

## Sets the property name
func set_name(name: String):
	self.name = name

## Initialization hook - override in derived classes
func on_init():
	pass
