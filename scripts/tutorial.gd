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

# Load pause menu
const PausePopup = preload("res://scripts/pause_popup.gd")

# Current tutorial level number
var tut_num = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set background color and buttons based on skin option
	match int(globals.pers_opts["skin"]):
		1:
			backg.color = globals.BACK_DARK
			pause_btn.texture_normal = load("res://assets/icons/pause_dark.png")
		_:
			backg.color = globals.BACK_LIGHT
			pause_btn.texture_normal = load("res://assets/icons/pause_light.png")
	# Load in level from file
	graph.load_puzzle('tut1')
	# Draw everything on screen
	graph.display_graph()
	# Play mouse clicking animation
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
			# Move and mirror clicking animation
			click.position = Vector2(1200,120)
			click.set_flip_h(true)
		2:
			# Go to main menu
			queue_free()
			get_tree().change_scene("res://scenes/main_menu.tscn")
	# Display new graph
	graph.display_graph()
	# Fade display back in
	animation.play("fadein")
	yield(animation, "animation_finished")
	# Restart clicking animation
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
	var popup = PausePopup.new()
	add_child(popup)
	popup.popup_centered_minsize(Vector2(100,50))
	get_tree().set_pause(true)
