extends Node

# Get file IO functions
const FileIO = preload("res://scripts/file_io.gd")

# Preload the credits menu to be passed back to menu frame
const cred_menu = preload("res://scenes/credits_menu.tscn")

# GUI objects
onready var diff_sel = get_node("difficulty_selector")
onready var skin_sel = get_node("skin_selector")
onready var reset_btn = get_node("reset")
onready var attrib_btn = get_node("attribs")

# Menu text arrays
var diff_array = ["Easy", "Medium", "Hard"]
var skin_array = ["Light", "Dark", "Red-Green Colorblind"]

func _ready():
	# Setup option UIs
	setup_diff_picker()
	setup_skin_picker()
	# Connect options UIs to respective functions
	diff_sel.connect("item_selected", self, "on_diff_selected")
	skin_sel.connect("item_selected", self, "on_skin_selected")
	reset_btn.connect("pressed", self, "set_defaults")
	attrib_btn.connect("pressed", self, "show_attributions")

func setup_diff_picker():
	# Add each difficulty to the dropdown
	for item in diff_array:
		diff_sel.add_item(item)
	# Select saved option
	diff_sel.select(globals.opts_data["diff"])

func setup_skin_picker():
	# Add each skin name to the dropdown
	for item in skin_array:
		skin_sel.add_item(item)
	# Select saved option
	skin_sel.select(globals.opts_data["theme"])

func on_diff_selected(item):
	# Save selected difficulty to project config
	globals.opts_data["diff"] = item
	FileIO.write_json_file(globals.opts_filepath, globals.opts_data)

func on_skin_selected(item):
	# Save selected option to project config
	globals.opts_data["theme"] = item
	FileIO.write_json_file(globals.opts_filepath, globals.opts_data)
	# Show theme popup to offer reload
	theme_popup()

func show_attributions():
	# Show attributions page
	get_parent().get_parent().stack_menu(cred_menu)

func set_defaults():
	# Write default values to options file
	globals.opts_data["diff"] = 0
	globals.opts_data["theme"] = 0
	FileIO.write_json_file(globals.opts_filepath, globals.opts_data)
	# Change UI elements to defaults
	diff_sel.select(globals.opts_data["diff"])
	skin_sel.select(globals.opts_data["theme"])

# Create a popup for reloading the game
func theme_popup():
	# Create a popup telling user to reload to apply theme
	var popup = ConfirmationDialog.new()
	popup.get_label().set_text("Reload game to apply theme?")
	# Set the affirmative button to open the tutorials
	popup.get_ok().connect("pressed", get_tree(), "reload_current_scene")
	# Show popup
	add_child(popup)
	popup.popup_centered_minsize()
