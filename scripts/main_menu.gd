extends Node

# Make sure the globals file is loaded
var glob = preload("res://scripts/globals.gd")

# Button objects
onready var cont_btn = get_node("menu_container/cont_button")
onready var level_btn = get_node("menu_container/level_button")
onready var recs_btn = get_node("menu_container/records_button")
onready var opt_btn = get_node("menu_container/opt_button")
onready var quit_btn = get_node("menu_container/quit_button")

func _ready():
	# Set background color if dark mode
	match int(globals.pers_opts["skin"]):
		1:
			get_node("background").color = globals.BACK_DARK
		_:
			get_node("background").color = globals.BACK_LIGHT
	# Check if user has completed tutorials
	if !globals.user_data.has("tutorials"):
		# If not, add a var to the file and write it
		globals.user_data["tutorials"] = true
		globals.update_last_level()
		# Show the tutorials popup
		tut_popup()
	# Connect buttons to respective functions
	cont_btn.connect("pressed", self, "return_level")
	level_btn.connect("pressed", self, "choose_level")
	recs_btn.connect("pressed", self, "open_records")
	opt_btn.connect("pressed", self, "open_options")
	quit_btn.connect("pressed", self, "quit_game")

# Return to last unsolved puzzle
func return_level():
	# Load instance of game scene
	var level_scene = ResourceLoader.load("res://scenes/game.tscn")
	get_tree().get_root().add_child(level_scene.instance())

# Choose level number from list
func choose_level():
	get_tree().change_scene("res://scenes/lvl_menu.tscn")

# Open the records list
func open_records():
	get_tree().change_scene("res://scenes/records_menu.tscn")

# Open the options menu
func open_options():
	get_tree().change_scene("res://scenes/opts_menu.tscn")

# Open the tutorial levels
func open_tutorials():
	self.queue_free()
	get_tree().change_scene("res://scenes/tutorial.tscn")

# Close the game
func quit_game():
	get_tree().quit()

# Create a popup for new users
func tut_popup():
	# Create a popup asking if user wants to play the tutorial
	var popup = ConfirmationDialog.new()
	popup.get_label().set_text("It looks like this is your first time.  Play the tutorial?")
	# Set the affirmative button to open the tutorials
	popup.get_ok().connect("pressed", self, "open_tutorials")
	# Show popup
	add_child(popup)
	popup.popup_centered_minsize()