extends Node

# Get file IO functions
const FileIO = preload("res://scripts/file_io.gd")

# GUI objects
onready var back_btn = get_node("back_btn")
onready var diff_sel = get_node("opts_menu_container/difficulty_selector")
onready var skin_sel = get_node("opts_menu_container/skin_selector")
onready var reset_btn = get_node("opts_menu_container/reset")
onready var attrib_btn = get_node("opts_menu_container/attribs")

# Menu text arrays
var diff_array = ["Easy", "Medium", "Hard"]
var skin_array = ["Light", "Dark"]

func _ready():
	# Set background color and back button if dark mode
	match int(globals.pers_opts["skin"]):
		1:
			get_node("background").color = globals.BACK_DARK
			back_btn.texture_normal = load("res://assets/icons/back_dark.png")
		_:
			get_node("background").color = globals.BACK_LIGHT
			back_btn.texture_normal = load("res://assets/icons/back_light.png")
	# Connect back button to close function
	back_btn.connect("pressed", self, "close_menu")
	# Setup option UIs
	setup_diff_picker()
	setup_skin_picker()
	# Connect options UIs to respective functions
	diff_sel.connect("item_selected", self, "on_diff_selected")
	skin_sel.connect("item_selected", self, "on_skin_selected")
	reset_btn.connect("pressed", self, "set_defaults")
	attrib_btn.connect("pressed", self, "show_attributions")

func close_menu():
	# Save options
	FileIO.write_json_file(globals.opts_filepath, globals.pers_opts)
	# Return to main menu
	get_tree().change_scene("res://scenes/main_menu.tscn")

func setup_diff_picker():
	# Add each difficulty to the dropdown
	for item in diff_array:
		diff_sel.add_item(item)
	# Select saved option
	diff_sel.select(globals.pers_opts["difficulty"])

func setup_skin_picker():
	# Add each difficulty to the dropdown
	for item in skin_array:
		skin_sel.add_item(item)
	# Select saved option
	skin_sel.select(globals.pers_opts["skin"])

func on_diff_selected(item):
	# Save selected difficulty to pers_opts
	globals.pers_opts["difficulty"] = item

func on_skin_selected(item):
	# Save selected boolean to pers_opts
	globals.pers_opts["skin"] = item

func show_credits():
	# Todo: Add attributions page
	pass

func set_defaults():
	# Write default values to options file
	globals.pers_opts = globals.get_options_defaults()
	FileIO.write_json_file(globals.opts_filepath, globals.pers_opts)
	# Change UI elements to defaults
	diff_sel.select(globals.pers_opts["difficulty"])
	skin_sel.select(globals.pers_opts["skin"])
