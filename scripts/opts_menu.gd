extends Node

# Get file IO functions
const FileIO = preload("res://scripts/file_io.gd")

# Constant file paths
const opts_filepath = "user://options.json"

# GUI objects
onready var back_btn = get_node("back_btn")
onready var opts_sel = get_node("opts_menu_container/difficulty_selector")

# Menu text arrays
var diff_array = ["Easy", "Medium", "Hard"]

# Saved options
var pers_opts = {"difficulty":0}

func _ready():
	# Get saved options (if they exist)
	if File.new().file_exists(opts_filepath):
		pers_opts = FileIO.read_json_file(opts_filepath)
	else:
		# TODO: Setup default options
		pass
	# Connect back button to close function
	back_btn.connect("pressed", self, "close_menu", [])
	# Setup difficulty dropdown
	setup_diff_picker()

func close_menu():
	# Save options
	FileIO.write_json_file(opts_filepath, pers_opts)
	# Return to main menu
	get_tree().change_scene("res://scenes/main_menu.tscn")

func setup_diff_picker():
	# Add each difficulty to the dropdown
	for item in diff_array:
		opts_sel.add_item(item)
	# Select saved option
	opts_sel.select(pers_opts["difficulty"])
