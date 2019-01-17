extends Control

# Preload main menu scene
const main_menu = preload("res://scenes/main_menu.tscn")

# Load UI elements
onready var background = get_node("background")
onready var back_btn = get_node("back_btn")
onready var menu_cont = get_node("menu")

# Animation players
onready var btn_anim = get_node("btn_anim")
onready var menu_anim = get_node("menu_anim")

# Stack of menu scenes
var menu_stack = []

func _ready():
	# Set background color if dark mode
	match int(ProjectSettings.get_setting("gui/theme/skin")):
		1:
			background.color = globals.BACK_DARK
		_:
			background.color = globals.BACK_LIGHT
	# Check if user has completed tutorials
	if !ProjectSettings.get_setting("game/tutorial_played"):
		# If not, add a var to the file and write it
		ProjectSettings.set("game/tutorial_played", true)
		ProjectSettings.save()
		# Show the tutorials popup
		tut_popup()
	# Load the main menu first
	stack_menu(main_menu)
	# Make back button invisible
	back_btn.visible = false
	# Connect back button to pop function
	back_btn.connect("pressed", self, "pop_menu")

func stack_menu(scene):
	# Fade out the old scene to hide switch
	fade_out()
	# Clear the menu container
	for node in menu_cont.get_children():
		node.queue_free()
		menu_cont.remove_child(node)
	# Add a new scene to the stack
	menu_stack.append(scene)
	# Display the scene on top
	menu_cont.add_child(menu_stack.back().instance())
	fade_in()

func pop_menu():
	# Fade out the old scene to hide switch
	fade_out()
	# Clear the menu container
	for node in menu_cont.get_children():
		node.queue_free()
		menu_cont.remove_child(node)
	# Remove the top-most scene
	menu_stack.pop_back()
	# Display the new top scene
	menu_cont.add_child(menu_stack.back().instance())
	fade_in()

# Fade out menu and back button
func fade_out():
	# Fade out the old scene to hide switch
	menu_anim.play("menu_fade_out")
	btn_anim.play("btn_fade_out")
	# Make back button invisible to prevent phantom clicks
	back_btn.visible = false

# Fade in menu and, if appropriate, back button
func fade_in():
	# Fade menu back in
	menu_anim.play("menu_fade_in")
	# Show the back button if the scene isn't the root menu
	if menu_stack.back().resource_path != main_menu.resource_path:
		back_btn.visible = true
		btn_anim.play("btn_fade_in")

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

# Open the tutorial levels
func open_tutorials():
	self.queue_free()
	get_tree().change_scene("res://scenes/tutorial.tscn")
