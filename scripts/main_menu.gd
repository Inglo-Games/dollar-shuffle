extends Node

# Button objects
onready var cont_btn = get_node("menu_container/cont_button")
onready var level_btn = get_node("menu_container/level_button")
onready var opt_btn = get_node("menu_container/opt_button")
onready var quit_btn = get_node("menu_container/quit_button")

func _ready():
	# Connect buttons to respective functions
	cont_btn.connect("pressed", self, "return_level", [])
	level_btn.connect("pressed", self, "choose_level", [])
	opt_btn.connect("pressed", self, "open_options", [])
	quit_btn.connect("pressed", self, "quit_game", [])

# Return to last unsolved puzzle
func return_level():
	get_tree().change_scene("res://scenes/game.tscn")

# Choose level number from list
func choose_level():
	get_tree().change_scene("res://scenes/lvl_menu.tscn")

# Open the options menu
func open_options():
	get_tree().change_scene("res://scenes/opts_menu.tscn")

# Close the game
func quit_game():
	get_tree().quit()