extends Popup

# UI Elements
onready var label = get_node("vbox/level_label")
onready var res_btn = get_node("vbox/resume_button")
onready var quit_btn = get_node("vbox/quit_button")

# Called when object is created
func _ready():
	
	set_process_input(true)
	
	# Set label to show current level name
	label.set_text("Puzzle ID: %s" % str(globals.opts_data["last"]))
	
	res_btn.connect("pressed", self, "resume")
	quit_btn.connect("pressed", self, "quit")

# Resume the game
func resume():
	
	get_parent().get_tree().set_pause(false)
	get_parent().get_node("pause_background").visible = false
	queue_free()

# Quit back to main menu
func quit():
	
	get_parent().get_tree().set_pause(false)
	get_parent().queue_free()
	get_tree().change_scene("res://scenes/menu_frame.tscn")
