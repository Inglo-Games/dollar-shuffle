extends Node

# Preload all menus accessable from this one
const LvlMenu = preload("res://scenes/lvl_menu.tscn")
const OptsMenu = preload("res://scenes/opts_menu.tscn")
const RecsMenu = preload("res://scenes/records_menu.tscn")

# Button objects
onready var cont_btn = $"cont_button"
onready var quit_btn = $"quit_button"

onready var click = $"click"

func _ready():
	
	# Only show continue button if there is a previous game
	if str(globals.opts_data["last"]) == "0" \
			or str(globals.opts_data["last"]) == "TUTORIALS":
		cont_btn.visible = false
	
	# Don't show useless quit button on HTML version
	if OS.get_name() == "HTML5":
		quit_btn.visible = false

# Return to last unsolved puzzle
func return_level():
	
	var level_scene = ResourceLoader.load("res://scenes/game.tscn")
	get_tree().get_root().add_child(level_scene.instance())

# Choose level number from list
func choose_level():
	
	get_parent().get_parent().stack_menu(LvlMenu)

# Open the records list
func open_records():
	
	get_parent().get_parent().stack_menu(RecsMenu)

# Open the options menu
func open_options():
	
	get_parent().get_parent().stack_menu(OptsMenu)

# Close the game
func quit_game():
	
	get_tree().quit()
