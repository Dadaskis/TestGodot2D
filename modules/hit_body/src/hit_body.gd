## Manages collision properties for interactive game objects
## Acts as a container for various hit detection and response properties

class_name HitBody

## Identifier for this type of object
const OBJECT_NAME = "__hit_body"

## Dictionary storing all hit properties
var properties = {}

## Reference to the parent node this belongs to
var node

## Adds a new hit property to this body [br]
## hit_name: String identifier for the property [br]
## value: HitBodyProperty instance to add
func add_hit_property(hit_name: String, value: HitBodyProperty):
	if not value:
		push_error("Value is null, most likely isn't extending HitBodyProperty")
		return
	if not is_instance_valid(node):
		push_error("node is not valid")
		return
	# Set up parent reference
	value.parent = node
	# Store in properties dictionary
	properties[hit_name] = value
	# Initialize the property
	value.on_init()

## Retrieves a hit property by name [br]
## hit_name: String identifier of the property to get [br]
## Returns: The HitBodyProperty or null if not found
func get_hit_property(hit_name: String):
	return properties.get(hit_name)
