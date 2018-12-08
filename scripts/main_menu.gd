extends Node

# Load file operations class
const FileIO = preload("res://scripts/file_io.gd")

# Button objects
onready var cont_btn = get_node("menu_container/cont_button")
onready var level_btn = get_node("menu_container/level_button")
onready var recs_btn = get_node("menu_container/records_button")
onready var opt_btn = get_node("menu_container/opt_button")
onready var quit_btn = get_node("menu_container/quit_button")

func _ready():
	# Set background color if dark mode
	if globals.pers_opts["darkmode"]:
		get_node("background").color = globals.BACK_DARK
	# Connect buttons to respective functions
	cont_btn.connect("pressed", self, "return_level")
	level_btn.connect("pressed", self, "choose_level")
	recs_btn.connect("pressed", self, "open_records")
	opt_btn.connect("pressed", self, "open_options")
	quit_btn.connect("pressed", self, "quit_game")

# Return to last unsolved puzzle
func return_level():
	var level_scene = ResourceLoader.load("res://scenes/game.tscn")
	get_tree().get_root().add_child(level_scene.instance())

# Choose level number from list
func choose_level():
	get_tree().change_scene("res://scenes/lvl_menu.tscn")

# Open the records list
func open_records():
	get_tree().change_scene("res://scenes/records_menu.tscn")

# Open the options menu
func open_options():
	get_tree().change_scene("res://scenes/opts_menu.tscn")

# Close the game
func quit_game():
	get_tree().quit()