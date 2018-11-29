extends Node

# GUI objects
onready var back_btn = get_node("back_btn")
onready var opts_sel = get_node("opts_menu_container/difficulty_selector")

# Menu text arrays
var diff_array = ["Easy", "Medium", "Hard"]

# Saved options
var pers_opts = {}

func _ready():
	# Connect back button to close function
	back_btn.connect("pressed", self, "close_menu", [])
	# Setup difficulty dropdown
	setup_diff_picker()

func close_menu():
	get_tree().change_scene("res://scenes/main_menu.tscn")

func setup_diff_picker():
	# Add each difficulty to the dropdown
	for item in diff_array:
		opts_sel.add_item(item)
