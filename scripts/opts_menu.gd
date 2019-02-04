extends Node

# Get file IO functions
const FileIO = preload("res://scripts/file_io.gd")

# Preload the credits menu to be passed back to menu frame
const CredMenu = preload("res://scenes/credits_menu.tscn")

# GUI objects
onready var diff_sel = $"difficulty_selector"
onready var skin_sel = $"skin_selector"

# Menu text arrays
var diff_array = ["Easy", "Medium", "Hard"]
var skin_array = ["Light", "Dark", "Red-Green Colorblind"]

func _ready():
	
	# Setup option UIs
	setup_diff_picker()
	setup_skin_picker()

func setup_diff_picker():
	
	for item in diff_array:
		diff_sel.add_item(item)
	diff_sel.select(globals.opts_data["diff"])

func setup_skin_picker():
	
	for item in skin_array:
		skin_sel.add_item(item)
	skin_sel.select(globals.opts_data["theme"])

func on_diff_selected(item):
	
	globals.opts_data["diff"] = item
	FileIO.write_json_file(globals.OPTS_FILEPATH, globals.opts_data)

func on_skin_selected(item):
	# Save selected option to project config
	globals.opts_data["theme"] = item
	FileIO.write_json_file(globals.OPTS_FILEPATH, globals.opts_data)

	theme_popup()

func show_attributions():
	# Show attributions page
	get_parent().get_parent().stack_menu(CredMenu)

func set_defaults():
	
	var old_theme = globals.opts_data["theme"]
	
	# Write default values to options file
	globals.opts_data["diff"] = 0
	globals.opts_data["theme"] = 0
	FileIO.write_json_file(globals.OPTS_FILEPATH, globals.opts_data)
	
	# Change UI elements to defaults
	diff_sel.select(globals.opts_data["diff"])
	skin_sel.select(globals.opts_data["theme"])
	
	# If theme changed, offer reload
	if old_theme != globals.opts_data["theme"]:
		theme_popup()

# Create a popup for reloading the game
func theme_popup():
	
	var popup = ConfirmationDialog.new()
	popup.get_label().set_text("Reload game to apply theme?")
	popup.get_ok().connect("pressed", get_tree(), "reload_current_scene")
	add_child(popup)
	popup.popup_centered_minsize()
