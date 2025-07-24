## Finite State Machine that powers AI in this game [br]
## Incredibly simple design, but pretty effective in the long term
class_name FiniteStateMachine

## Dictionary of all registered states
var states = {}
## Properties dictionary that is shared with all states
var properties = {}
## Current state that is processed by AI
var active_state: State
## Current state's name
var active_state_name = ""
## Character that is related to this machine
var character: Character

## Loads all states from a directory
func load_all_states_from_dir(path: String):
	var files = DirAccess.get_files_at(path)
	for file in files:
		if ".uid" in file:
			continue
		if not ".gd" in file:
			continue
		var script_path = path + file
		if not ResourceLoader.exists(script_path):
			continue
		var script = load(script_path)
		var state = script.new()
		var state_name = file.get_basename()
		register_state(state_name, state)

## Registers a new state
func register_state(state_name: String, state: State):
	state.properties = properties
	state.character = character
	state.on_register()
	state.switch_state.connect(switch_state)
	states[state_name] = state

## Switches to a different state
func switch_state(state_name: String):
	var state = states.get(state_name)
	if not state:
		return
	if active_state:
		active_state.before_switch()
	active_state = state
	active_state_name = state_name
	state.switch()

## Sets property for all states to use
func set_property(key, value):
	properties[key] = value

## Returns a state from the properties dictionary
func get_property(key):
	return properties.get(key)

## Updates active state
func update(delta: float):
	if not active_state:
		return
	active_state.update(delta)
