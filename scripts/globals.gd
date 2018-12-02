extends Node

# Global variables
var current_level = 1
var number_of_levels = -1

# Global functions

# Change current puzzle to next puzzle
func open_next_puzzle(scene):
	# Make sure that puzzle exists
	if current_level + 1 > number_of_levels:
		# Return to main menu
		scene.queue_free()
		get_tree().change_scene("res://scenes/main_menu.tscn")
		return
	# Else, increment level num and load new game scene
	current_level += 1
	scene.queue_free()
	scene = ResourceLoader.load("res://scenes/game.tscn")
	get_tree().get_root().add_child(scene.instance())
