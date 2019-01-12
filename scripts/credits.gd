extends Node

# GUI objects
onready var back_btn = get_node("back_btn")
onready var vid_btn = get_node("vbox/vid_btn")

func _ready():
	# Set background color and back button if dark mode
	match int(ProjectSettings.get_setting("gui/theme/skin")):
		1:
			get_node("background").color = globals.BACK_DARK
			back_btn.texture_normal = load("res://assets/icons/back_dark.png")
		_:
			get_node("background").color = globals.BACK_LIGHT
			back_btn.texture_normal = load("res://assets/icons/back_light.png")
	# Connect back button to close function
	back_btn.connect("pressed", self, "close_menu")
	# Connect video link button to YouTube video
	vid_btn.connect("pressed", self, "open_video")

func close_menu():
	# Return to options menu
	get_tree().change_scene("res://scenes/opts_menu.tscn")

func open_video():
	OS.shell_open("https://www.youtube.com/watch?v=U33dsEcKgeQ")
