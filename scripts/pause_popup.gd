extends Popup

signal resume_game

# UI Elements
onready var label = $"vbox/level_label"

# Called when object is created
func _ready():
	
	set_process_input(true)
	
	# Set label to show current level name
	label.set_text("Puzzle ID: %s" % str(globals.opts_data["last"]))

# Resume the game
func resume():
	
	get_tree().set_pause(false)
	emit_signal("resume_game")
	queue_free()

# Quit back to main menu
func quit():
	
	get_tree().set_pause(false)
	get_parent().queue_free()
	get_tree().change_scene("res://scenes/menu_frame.tscn")
