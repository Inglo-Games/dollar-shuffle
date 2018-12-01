extends PopupMenu

# Called when object is created
func _ready():
	set_process_input(true)
	# Add a 'resume' and 'quit' item
	add_item("resume", 0)
	add_item("quit", 1)
	# Connect 'pressed' signal to handler function
	connect("index_pressed", self, "handle_input")
	# Make sure this doesn't pause when parent does
	set_pause_mode(PAUSE_MODE_PROCESS)
	# Dont disappear if clicked outside
	popup_exclusive = true
	# Disappear when an option is selected
	hide_on_item_selection = true

# Handle button press
func handle_input(id):
	# Unpause no matter what
	get_parent().get_tree().set_pause(false)
	# If pressed resume...
	if id == 0:
		# Make the obscuring background disappear
		get_parent().get_node("pause_background").visible = false
		pass
	# If pressed quit...
	elif id == 1:
		# Go back to main menu
		get_parent().queue_free()
		get_tree().change_scene("res://scenes/main_menu.tscn")
		return
