extends Control

# UI Elements
onready var backg = get_node("background")
onready var click = get_node("node_ui_container/click_img")
onready var pause_btn = get_node("btn_container/pause_btn")
onready var node_cont = get_node("node_ui_container")
onready var animation = get_node("anim")
onready var audio = get_node("audio")

# Load the GameGraph classes
const GameGraph = preload("res://scripts/graph.gd")
const GameNode = preload("res://scripts/graph_node.gd")

# Load pause menu
const PausePopup = preload("res://scripts/pause_popup.gd")

# GameGraph object for this level
onready var graph

# Size for node UI
var radius = 60.0

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
	graph = GameGraph.new()
	graph.load_puzzle('tut1')
	# Draw everything on screen
	display_graph()
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
			click.position = Vector2(1180,140)
			click.set_flip_h(true)
		2:
			# Go to main menu
			queue_free()
			get_tree().change_scene("res://scenes/main_menu.tscn")
	# Display new graph
	display_graph()
	# Fade display back in
	animation.play("fadein")
	yield(animation, "animation_finished")
	# Restart clicking animation
	animation.play("leftclick")

# Draw entire graph on screen
func display_graph():
	# Draw connection lines first so they appear behind the nodes
	# For each connection...
	for node in graph.graph_data.keys():
		for connection in graph.graph_data[node]["conns"]:
			# Draw a line between the two
			draw_conn_line(connection, node)
	# For each node in the graph...
	for index in range(len(graph.graph_data)):
		draw_node(index)

# Draw a single node on the screen
func draw_node(num):
	# Convert location to pixel coords
	var location = Vector2(0,0)
	location.x = graph.graph_data[str(num)]["loc"][0] * get_viewport().size.x
	location.y = graph.graph_data[str(num)]["loc"][1] * get_viewport().size.y
	# Create GameNode object to add to screen
	var game_node = GameNode.new()
	game_node.initialize(num, radius)
	game_node.rect_position = location
	# Add node as child once loading is finished
	node_cont.call_deferred("add_child", game_node)
	# Add node to group
	game_node.add_to_group("ui_nodes")

# Draw a line connecting 2 nodes
func draw_conn_line(n1, n2):
	# Draw line between given nodes
	var loc1x = graph.graph_data[str(n1)]["loc"][0] * get_viewport().size.x
	var loc1y = graph.graph_data[str(n1)]["loc"][1] * get_viewport().size.y
	var loc1 = Vector2(loc1x, loc1y)
	var loc2x = graph.graph_data[str(n2)]["loc"][0] * get_viewport().size.x
	var loc2y = graph.graph_data[str(n2)]["loc"][1] * get_viewport().size.y
	var loc2 = Vector2(loc2x, loc2y)
	var line = Line2D.new()
	line.add_point(loc1)
	line.add_point(loc2)
	match int(globals.pers_opts["skin"]):
		1:
			line.default_color = globals.LIGHT_GREY
		_:
			line.default_color = globals.BLACK
	node_cont.call_deferred("add_child", line)
	line.add_to_group("ui_lines")

# Callback to give points to neighbors
func node_give_points(node):
	# Give points to all neighbors
	graph.give_points(node)
	# Update nodes UI
	get_tree().call_group("ui_nodes", "update")
	# Check if player has solved puzzle
	check_win_condition()

# Callback for taking points
func node_take_points(node):
	# Take points from all neighbors
	graph.take_points(node)
	# Update nodes UI
	get_tree().call_group("ui_nodes", "update")
	# Check if player has solved puzzle
	check_win_condition()

# Check whether the player has solved the puzzle
func check_win_condition():
	# Check the value of each node, should be non-negative
	for node in graph.graph_data.keys():
		if graph.graph_data[node]["value"] < 0:
			return false
	# If the function hasn't returned yet, all nodes passed check
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
