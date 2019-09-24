extends Control

# UI Elements
onready var backg = $"background_layer/background"
onready var graph = $"node_ui_container"
onready var click = $"node_ui_container/click_img"
onready var pause_btn = $"ui_layer/pause_btn"
onready var fade_anim = $"fade_anim"
onready var click_anim = $"click_anim"
onready var audio = $"audio"

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
	
	mobile = (OS.get_name() == "Android") or (OS.get_name() == "iOS") 
	
	# Load in level from file
	graph.load_puzzle('tut1')
	globals.update_last_level('TUTORIALS')
	
	graph.display_graph()
	
	# Play clicking or tapping animation
	move_click_image()
	if mobile:
		click.scale = Vector2(0.75, 0.75)
		click_anim.play("short_tap")
	else:
		click_anim.play("leftclick")

# Clear the graph and load next tutorial
func transition_graph():
	
	# Play the victory audio track
	audio.play()
	
	# Play the fade-out animation to hide transition
	fade_anim.stop()
	fade_anim.seek(0.0, true)
	fade_anim.play("fadeout")
	yield(fade_anim, "animation_finished")
	
	# Clear out old graph
	get_tree().call_group("ui_nodes", "queue_free")
	get_tree().call_group("ui_lines", "queue_free")
	 
	# Transition depends on current puzzle
	match tut_num:
		1:
			tut_num = 2
			graph.load_puzzle('tut2')
		2:
			tut_num = 3
			graph.load_puzzle('tut3')
		3:
			tut_num = 4
			graph.load_puzzle('tut4')
		4:
			# Go to main menu
			queue_free()
			get_tree().change_scene("res://scenes/menu_frame.tscn")
	
	graph.display_graph()
	move_click_image()
	
	# Setup tapping animation for mobile
	if mobile:
		if tut_num == 3:
			click_anim.play("short_tap")
		else:
			click_anim.play("long_tap")
	# Setup clicking animation for non-mobile
	else:
		click.set_flip_h( ! (tut_num % 2))
		click_anim.play("leftclick")
	
	# Fade display back in
	fade_anim.play("fadein")
	yield(fade_anim, "animation_finished")

# Move the clicking animation to the left of the given node
func move_click_image():
	
	# Get the size and position of the first (zeroth) node
	var node = graph.node_list[0]
	var pos = Vector2(node.margin_left, node.margin_top)
	var radius = graph.ui_scale.x * 256
	
	# Move the click image to left of node
	click.position = Vector2(pos.x - radius / 2.0, pos.y + radius)

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
	get_node("ui_layer/pause_background").visible = true
	
	# Create and show pause menu
	var popup = PausePopup.instance()
	$ui_layer.add_child(popup)
	popup.popup_centered()
	get_tree().set_pause(true)
