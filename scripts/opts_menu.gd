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
	diff_sel.select(ProjectSettings.get_setting("game/difficulty"))

func setup_skin_picker():
	# Add each skin name to the dropdown
	for item in skin_array:
		skin_sel.add_item(item)
	# Select saved option
	skin_sel.select(ProjectSettings.get_setting("gui/theme/skin"))

func on_diff_selected(item):
	# Save selected difficulty to project config
	ProjectSettings.set("game/difficulty", item)
	ProjectSettings.save()

func on_skin_selected(item):
	# Save selected option to project config
	ProjectSettings.set("gui/theme/skin", item)
	# Set global theme to selected one
	match item:
		# Dark mode
		1:
			ProjectSettings.set_setting("gui/theme/custom","res://assets/dark_theme.tres")
		# Light and colorblind mode
		_:
			ProjectSettings.set_setting("gui/theme/custom","res://assets/light_theme.tres")
	# Save the result to settings file
	ProjectSettings.save()

func show_attributions():
	# Show attributions page
	get_parent().get_parent().stack_menu(cred_menu)

func set_defaults():
	# Write default values to options file
	ProjectSettings.set("game/difficulty", 0)
	ProjectSettings.set("gui/theme/skin", 0)
	# Change UI elements to defaults
	diff_sel.select(ProjectSettings.get_setting("game/difficulty"))
	skin_sel.select(ProjectSettings.get_setting("gui/theme/skin"))
