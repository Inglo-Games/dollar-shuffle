extends Popup

# UI Elements
onready var label = get_node("vbox/level_label")
onready var res_btn = get_node("vbox/resume_button")
onready var quit_btn = get_node("vbox/quit_button")

# Called when object is created
func _ready():
	set_process_input(true)
	# Set label to show current level name
	label.set_text("Puzzle ID: %s" % str(ProjectSettings.get_setting("game/last_played")))
	# Connect buttons to respective functions
	res_btn.connect("pressed", self, "resume")
	quit_btn.connect("pressed", self, "quit")

# Resume the game
func resume():
	# Unpause the game
	get_parent().get_tree().set_pause(false)
	# Make the obscuring background disappear
	get_parent().get_node("pause_background").visible = false
	# Dismiss this popup
	queue_free()

# Quit back to main menu
func quit():
	# Unpause the game
	get_parent().get_tree().set_pause(false)
	# Go back to main menu
	get_parent().queue_free()
	get_tree().change_scene("res://scenes/menu_frame.tscn")
