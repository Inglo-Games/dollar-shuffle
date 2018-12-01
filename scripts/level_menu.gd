extends Node

# Get referenced classes
const FileIO = preload("res://scripts/file_io.gd")
const LevelClass = preload("res://scripts/level.gd")

# GUI objects
onready var back_btn = get_node("back_btn")
onready var lvl_list = get_node("lvl_list")

func _ready():
	# Populate the list with levels
	populate_list()
	# Connect list to function that opens levels
	lvl_list.connect("item_selected", self, "open_level", []) 
	# Connect back button to return function
	back_btn.connect("pressed", self, "close_menu", [])

func populate_list():
	# Create an item in the list for each one
	for index in range(global_vars.number_of_levels):
		lvl_list.add_item(str(index+1))

func open_level(num):
	# Save level number to global var
	global_vars.current_level = num+1
	# Move to scene for level selected
	get_tree().change_scene("res://scenes/game.tscn")
	
func close_menu():
	# Return to main menu
	get_tree().change_scene("res://scenes/main_menu.tscn")
