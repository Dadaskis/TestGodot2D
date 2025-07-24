class_name FiniteStateMachine

var states = {}
var properties = {}
var active_state: State

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

func register_state(state_name: String, state: State):
	state.properties = properties
	state.on_register()
	state.switch_state.connect(switch_state)
	states[state_name] = state

func switch_state(state_name: String):
	var state = states.get(state_name)
	if not state:
		return
	if active_state:
		active_state.before_switch()
	active_state = state
	state.switch()

func set_property(key, value):
	properties[key] = value

func get_property(key):
	return properties.get(key)

func update(delta: float):
	if not active_state:
		return
	active_state.update(delta)
