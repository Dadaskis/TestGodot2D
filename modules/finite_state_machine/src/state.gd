## One of the states that can be a part of Finite State Machine

class_name State

## Properties that are possessed by Finite State Machine itself
var properties = {}
## Character that is running the logic
var character: Character

## Signal that'll switch the state
signal switch_state(state_name)

## Called when Finite State Machine registers this state
func on_register():
	pass

## Called when Finite State Machine switches to this state
func on_switch():
	pass

## Called when Finite State Machine is about to switch from this state
func on_before_switch():
	pass

## Called on every update
func on_update(delta):
	pass

## Runs switch logic
func switch():
	on_switch()

## Runs before switch logic
func before_switch():
	on_before_switch()

## Runs update logic
func update(delta: float):
	on_update(delta)

## Runs set property
func set_property(key, value):
	properties[key] = value

## Runs get property
func get_property(key):
	return properties.get(key)
