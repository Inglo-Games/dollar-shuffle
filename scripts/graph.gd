# This represents the graph (nodes and connections) for each puzzle
extends Node

# Load the GameNode classes
const GameNode = preload("res://scripts/graph_node.gd")
const GameGen = preload("res://scripts/graph_gen.gd")

# Load the point animation class
const PointAnimation = preload("res://scripts/point_anim.gd")

# Dictionary containing all graph data
var graph_data = {}

# List of node UI objects
var node_list = []

# Containers for lines, animations, and nodes
onready var line_cont = $lines_layer
onready var anim_cont = $points_layer
onready var node_cont = $nodes_layer

# Scale to use for all UI elements
var ui_scale = Vector2(1.0, 1.0)

# Tweens to use for fade-in and fade-out anims
var fade_in = Tween.new()
var fade_out = Tween.new()

func load_puzzle(input):
	
	node_list = []
	
	# If it's an int, load that level number
	if typeof(input) == TYPE_INT:
		var filepath = "res://levels/%03d.lvl" % input
		var file = File.new()
		file.open(filepath, file.READ)
		graph_data = file.get_var()
		file.close()
	
	# If it's the string 'tut', load the tutorials
	elif str(input).matchn('tut1'):
		load_tutorial(1)
	elif str(input).matchn('tut2'):
		load_tutorial(2)
	elif str(input).matchn('tut3'):
		load_tutorial(3)
	elif str(input).matchn('tut4'):
		load_tutorial(4)
	
	# If it's another string, load a random graph
	elif typeof(input) == TYPE_STRING:
		graph_data = GameGen.generate_graph_data()
	
	# Set the scale value
	ui_scale = Vector2(2.0 / (len(graph_data) + 1), 2.0 / (len(graph_data) + 1))
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		ui_scale *= 1.3

# Load a tutorial level
func load_tutorial(num):
	var filepath = "res://levels/tuts/%d.lvl" % num
	var file = File.new()
	file.open(filepath, file.READ)
	graph_data = file.get_var()
	file.close()

# Take one point from each neighbor of a given node and add that many to it
func take_points(node):
	
	# Take one from each neighbor
	for neighbor in graph_data[node]["conns"]:
		graph_data[neighbor]["value"] -= 1
		
		# Create an animation to show point moving
		var anim = PointAnimation.new()
		anim.init(node_list[neighbor], node_list[node])
		anim.scale = ui_scale
		anim_cont.add_child(anim)
	
	# Add number of neighbors to node value
	graph_data[node]["value"] += len(graph_data[node]["conns"])
	
	# Update move list and score label
	get_parent().moves.append(Vector2(node, -1))
	get_parent().update_score()
	
	check_win_condition()
	
	# Wait for animations to play out before updating node labels
	yield(get_tree().create_timer(0.6), "timeout")
	get_tree().call_group("ui_nodes", "update")

# Add one point to each neighbor from given node
func give_points(node):
	
	# Subtract one for each neighbor
	graph_data[node]["value"] -= len(graph_data[node]["conns"])
	
	# Add one to each neighbor
	for neighbor in graph_data[node]["conns"]:
		graph_data[neighbor]["value"] += 1
		
		# Create an animation to show point moving
		var anim = PointAnimation.new()
		anim.init(node_list[node], node_list[neighbor])
		anim.scale = ui_scale
		anim_cont.add_child(anim)
	
	# Update move list and score label
	get_parent().moves.append(Vector2(node, 1))
	get_parent().update_score()
	
	check_win_condition()
	
	# Wait for animations to play out before updating nodes
	yield(get_tree().create_timer(0.6), "timeout")
	get_tree().call_group("ui_nodes", "update")

# Draw entire graph on screen
func display_graph():
	
	# For each connection between nodes...
	for node in graph_data.keys():
		for connection in graph_data[node]["conns"]:
			# Draw a line between the two
			draw_conn_line(connection, node)
	
	# For each node in the graph...
	for index in range(len(graph_data)):
		draw_node(index)
	
	fade_in.start()
	yield(fade_in, "tween_all_completed")
	fade_in.remove_all()

# Draw a single node on the screen
func draw_node(num):
	
	# Convert location to pixel coords
	var location = Vector2(0, 0)
	location.x = graph_data[num]["loc"].x * get_viewport().size.x
	location.y = graph_data[num]["loc"].y * get_viewport().size.y
	
	# Create GameNode object to add to screen
	var game_node = GameNode.new()
	game_node.initialize(num)
	game_node.rect_position = location
	
	# Scale and position node
	game_node.rect_size = Vector2(512,512)
	game_node.rect_scale = ui_scale
	location -= Vector2(512,512) * ui_scale * 0.5
	game_node.rect_position = location
	
	node_cont.add_child(game_node)
	game_node.add_to_group("ui_nodes")
	node_list.append(game_node)
	
	# Add node to tweens
	#game_node.modulate = Color(1, 1, 1, 0)
	fade_in.interpolate_property(game_node, "modulate:a", 0, 1, 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN)
	fade_out.interpolate_property(game_node, "modulate:a", 1, 0, 0.75, Tween.TRANS_LINEAR, Tween.EASE_OUT)

# Draw a line connecting 2 nodes
func draw_conn_line(n1, n2):
	
	# Determine centerpoints of each node
	var loc1x = graph_data[n1]["loc"].x * get_viewport().size.x
	var loc1y = graph_data[n1]["loc"].y * get_viewport().size.y
	var loc1 = Vector2(loc1x, loc1y)
	var loc2x = graph_data[n2]["loc"].x * get_viewport().size.x
	var loc2y = graph_data[n2]["loc"].y * get_viewport().size.y
	var loc2 = Vector2(loc2x, loc2y)
	
	# Draw line between given nodes
	var line = Line2D.new()
	line.add_point(loc1)
	line.add_point(loc2)
	
	# Color the line depending on theme
	match int(globals.opts_data["theme"]):
		1:
			line.default_color = globals.LIGHT_GREY
		_:
			line.default_color = globals.BLACK
	
	# Add line to scene and lines group
	line_cont.add_child(line)
	line.add_to_group("ui_lines")
	
	# Add line to tweens
	#line.modulate = Color(1, 1, 1, 0)
	fade_in.interpolate_property(line, "modulate:a", 0, 1, 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN)
	fade_out.interpolate_property(line, "modulate:a", 1, 0, 0.75, Tween.TRANS_LINEAR, Tween.EASE_OUT)

# Check whether the player has solved the puzzle
func check_win_condition():
	
	# Check the value of each node, should be non-negative
	for node in graph_data.keys():
		if graph_data[node]["value"] < 0:
			return false
	
	# If the function hasn't returned yet, all nodes passed check
	# Once puzzle is solved, stop allowing clicks
	get_tree().call_group("ui_nodes", "set_process_input", false)
	
	# Wait for animations to play out before changing levels
	yield(get_tree().create_timer(0.6), "timeout")
	get_parent().open_next_puzzle()
