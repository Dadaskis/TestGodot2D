# __AUTOLOAD
# Globally accessible list of all characters.
# Contains two lists, one with alive characters and another one with dead ones.

extends Node

# A list with alive characters.
var list: Array = []
# A list with dead characters.
var dead_list: Array = []

# Add alive character into list.
func add_character(character) -> void:
	if character in list:
		return
	list.append(character)

# Remove character from list of alive characters.
func remove_character(character) -> void:
	list.erase(character)
	if character in list:
		remove_character(character)

# Add dead character into list.
func add_dead_character(character) -> void:
	dead_list.append(character)

# Remove character from list of dead characters.
func remove_dead_character(character) -> void:
	dead_list.erase(character)

# Returns an array of alive characters.
func get_character_list() -> Array:
	return list

# Returns an array of dead characters.
func get_dead_character_list() -> Array:
	return dead_list

# Clears both alive and dead character lists.
func clear_list() -> void:
	print("[CharacterList] Reset!")
	print_stack()
	list.clear()
	dead_list.clear()
