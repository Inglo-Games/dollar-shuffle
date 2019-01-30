extends Control

# UI Elements
onready var backg = get_node("background")
onready var graph = get_node("node_ui_container")
onready var click = get_node("node_ui_container/click_img")
onready var pause_btn = get_node("btn_container/pause_btn")
onready var animation = get_node("anim")
onready var audio = get_node("audio")

# Load the GameGraph classes
const GameGraph = preload("res://scripts/graph.gd")

# Preload pause menu
const PausePopup = preload("res://scenes/pause_popup.tscn")

# Current tutorial level number
var tut_num = 1

# Moves list isn't used in tutorial, but is called in graph.gd
var moves = []

# Set this flag if this is a mobile platform
var mobile = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set background color and buttons based on skin option
	match int(globals.opts_data["theme"]):
		1:
			theme = load("res://assets/dark.theme")
			backg.color = globals.BACK_DARK
			pause_btn.texture_normal = load("res://assets/icons/pause_dark.png")
		_:
			theme = load("res://assets/light.theme")
			backg.color = globals.BACK_LIGHT
			pause_btn.texture_normal = load("res://assets/icons/pause_light.png")
	# Check for mobile platform
	mobile = (OS.get_name() == "Android") or (OS.get_name() == "iOS") 
	# Load in level from file
	graph.load_puzzle('tut1')
	globals.update_last_level('TUTORIALS')
	# Draw everything on screen
	graph.display_graph()
	# Play clicking or tapping animation
	if mobile:
		click.scale = Vector2(0.75, 0.75)
		animation.play("short_tap")
	else:
		animation.play("leftclick")
	# Connect pause button to function
	pause_btn.connect("pressed", self, "toggle_pause")

# Clear the graph and load next tutorial
func transition_graph():
	# Play the victory audio track
	audio.play()
	# Play the fade-out animation to hide transition
	animation.stop()
	animation.seek(0.0, true)
	animation.play("fadeout")
	yield(animation, "animation_finished")
	# Clear out old graph
	get_tree().call_group("ui_nodes", "queue_free")
	get_tree().call_group("ui_lines", "queue_free")
	# Transition depends on current puzzle
	match tut_num:
		1:
			# Load next tutorial
			tut_num = 2
			graph.load_puzzle('tut2')
			# Move clicking animation
			if mobile:
				click.position = Vector2(1400,120)
			else:
				click.position = Vector2(1200,120)
		2:
			# Load next tutorial
			tut_num = 3
			graph.load_puzzle('tut3')
			# Move clicking animation
			click.position = Vector2(380,260)
		3:
			# Load next tutorial
			tut_num = 4
			graph.load_puzzle('tut4')
			# Move clicking animation
			click.position = Vector2(780,180)
		4:
			# Go to main menu
			queue_free()
			get_tree().change_scene("res://scenes/menu_frame.tscn")
	# Display new graph
	graph.display_graph()
	# Fade display back in
	animation.play("fadein")
	yield(animation, "animation_finished")
	# Setup tapping animation for mobile
	if mobile:
		if tut_num == 3:
			animation.play("short_tap")
		else:
			animation.play("long_tap")
	# Setup clicking animation for non-mobile
	else:
		click.set_flip_h(!(tut_num % 2))
		animation.play("leftclick")

# Called from graph.gd
func update_score():
	# Tutorial doesn't keep track of score
	pass

# Called from graph.gd
func open_next_puzzle():
	# Tutorial doesn't record wins -- just move on to next puzzle
	transition_graph()

# Pause game
func toggle_pause():
	# Make the obscuring background layer visible
	get_node("pause_background").visible = true
	# Create and show pause menu
	var popup = PausePopup.instance()
	add_child(popup)
	popup.popup_centered()
	get_tree().set_pause(true)
