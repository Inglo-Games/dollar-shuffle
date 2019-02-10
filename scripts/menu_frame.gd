extends Control

# Preload main menu scene
const MainMenu = preload("res://scenes/main_menu.tscn")

# Load UI elements
onready var background = $"background"
onready var back_btn = $"back_btn"
onready var menu_cont = $"menu"

# Animation players
onready var btn_anim = $"btn_anim"
onready var menu_anim = $"menu_anim"

# Stack of menu scenes
var menu_stack = []

func _ready():
	
	# Set background color and back arrow according to theme
	match int(globals.opts_data["theme"]):
		# Dark theme
		1:
			theme = load("res://assets/dark.theme")
			background.color = globals.BACK_DARK
			back_btn.texture_normal = load("res://assets/icons/back_dark.png")
		# Light and colorblind themes
		_:
			theme = load("res://assets/light.theme")
			background.color = globals.BACK_LIGHT
			back_btn.texture_normal = load("res://assets/icons/back_light.png")
	
	# Check if user has completed tutorials
	if !globals.opts_data["tut"]:
		# If not, add a var to the file and write it
		globals.opts_data["tut"] = true
		var FileIO = load("res://scripts/file_io.gd")
		FileIO.write_json_file(globals.opts_filepath, globals.opts_data)
		# Show the tutorials popup
		tut_popup()
	
	# Load the main menu first
	stack_menu(MainMenu)
	
	back_btn.visible = false
	back_btn.connect("pressed", self, "pop_menu")

func stack_menu(scene):
	
	# Don't play click on app open
	if len(menu_stack) != 0:
		$click.play()
	
	# Fade out the old scene to hide switch
	fade_out()
	
	# Clear the menu container
	for node in menu_cont.get_children():
		node.queue_free()
		menu_cont.remove_child(node)
	
	menu_stack.append(scene)
	menu_cont.add_child(menu_stack.back().instance())
	
	fade_in()

func pop_menu():
	
	$click.play()
	
	# Fade out the old scene to hide switch
	fade_out()
	
	# Clear the menu container
	for node in menu_cont.get_children():
		node.queue_free()
		menu_cont.remove_child(node)
		
	menu_stack.pop_back()
	menu_cont.add_child(menu_stack.back().instance())
	
	fade_in()

# Fade out menu and back button
func fade_out():
	
	menu_anim.play("menu_fade_out")
	btn_anim.play("btn_fade_out")
	
	# Make back button invisible to prevent phantom clicks
	back_btn.visible = false

# Fade in menu and, if appropriate, back button
func fade_in():
	
	menu_anim.play("menu_fade_in")
	
	# Show the back button if the scene isn't the root menu
	if menu_stack.back().resource_path != MainMenu.resource_path:
		back_btn.visible = true
		btn_anim.play("btn_fade_in")

# Create a popup for new users
func tut_popup():
	
	# Create a popup asking if user wants to play the tutorial
	var popup = ConfirmationDialog.new()
	popup.get_label().set_text("It looks like this is your first time.  Play the tutorial?")
	popup.get_ok().connect("pressed", self, "open_tutorials")
	add_child(popup)
	popup.popup_centered_minsize()

# Open the tutorial levels
func open_tutorials():
	
	self.queue_free()
	get_tree().change_scene("res://scenes/tutorial.tscn")
