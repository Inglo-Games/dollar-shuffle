# This represents the graph (nodes and connections) for each puzzle
extends Node

# Load the GameNode classes
const GameNode = preload("res://scripts/graph_node.gd")
const GameGen = preload("res://scripts/graph_gen.gd")

# Load the point animation class
const PointAnimation = preload("res://scripts/point_anim.gd")

# Get file IO functions
const FileIO = preload("res://scripts/file_io.gd")

# Dictionary containing all graph data
var graph_data = {}

# List of node UI objects
var node_list = []

# Scale to use for all UI elements
var ui_scale = Vector2(1.0, 1.0)

func load_puzzle(input):
	# Clear out old node list
	node_list = []
	# If it's an int, load that level number
	if typeof(input) == TYPE_INT:
		var filepath = "res://levels/%03d.json" % input
		graph_data = FileIO.read_json_file(filepath)
	# If it's the string 'tut', load the tutorials
	elif str(input).matchn('tut1'):
		graph_data = FileIO.read_json_file("res://levels/tuts/1.json")
	elif str(input).matchn('tut2'):
		graph_data = FileIO.read_json_file("res://levels/tuts/2.json")
	# If it's another string, load a random graph
	elif typeof(input) == TYPE_STRING:
		graph_data = GameGen.generate_graph_data()
	# Set the scale value
	ui_scale = Vector2(2.0 / (len(graph_data)+1), 2.0 / (len(graph_data)+1))

# Take one point from each neighbor of a given node and add that many to it
func take_points(node):
	# Take one from each neighbor
	for neighbor in graph_data[str(node)]["conns"]:
		graph_data[str(neighbor)]["value"] -= 1
		# Create an animation to show point moving
		var anim = PointAnimation.new()
		anim.init(node_list[neighbor], node_list[node])
		anim.scale = ui_scale
		call_deferred("add_child", anim)
	# Wait for animations to play out
	yield(get_tree().create_timer(0.6),"timeout")
	# Add that many to node
	graph_data[str(node)]["value"] += len(graph_data[str(node)]["conns"])
	# Update move list
	get_parent().moves.append(Vector2(node,-1))
	# Force redraw of all node's UI
	get_tree().call_group("ui_nodes", "update")
	# Update the score label
	get_parent().update_score()
	# Check for a win
	check_win_condition()

# Add one point to each neighbor from given node
func give_points(node):
	# Subtract one for each neighbor
	graph_data[str(node)]["value"] -= len(graph_data[str(node)]["conns"])
	# Add one to each neighbor
	for neighbor in graph_data[str(node)]["conns"]:
		graph_data[str(neighbor)]["value"] += 1
		# Create an animation to show point moving
		var anim = PointAnimation.new()
		anim.init(node_list[node], node_list[neighbor])
		anim.scale = ui_scale
		call_deferred("add_child", anim)
	# Wait for animations to play out
	yield(get_tree().create_timer(0.6),"timeout")
	# Update move list
	get_parent().moves.append(Vector2(node,1))
	# Force redraw of all node's UI
	get_tree().call_group("ui_nodes", "update")
	# Update the score label
	get_parent().update_score()
	# Check for a win
	check_win_condition()

# Draw entire graph on screen
func display_graph():
	# Draw connection lines first so they appear behind the nodes
	# For each connection...
	for node in graph_data.keys():
		for connection in graph_data[node]["conns"]:
			# Draw a line between the two
			draw_conn_line(connection, node)
	# For each node in the graph...
	for index in range(len(graph_data)):
		draw_node(index)

# Draw a single node on the screen
func draw_node(num):
	# Convert location to pixel coords
	var location = Vector2(0,0)
	location.x = graph_data[str(num)]["loc"][0] * get_viewport().size.x
	location.y = graph_data[str(num)]["loc"][1] * get_viewport().size.y
	# Create GameNode object to add to screen
	var game_node = GameNode.new()
	game_node.initialize(num)
	game_node.rect_position = location
	# Size control node equal to the node image
	game_node.rect_size = Vector2(512,512)
	# Scale down node according to how many there are
	game_node.rect_scale = ui_scale
	# Center Control node over location
	location -= (Vector2(512,512) * ui_scale * 0.5)
	game_node.rect_position = location
	# Add node as child once loading is finished
	call_deferred("add_child", game_node)
	# Add node to group and list
	game_node.add_to_group("ui_nodes")
	node_list.append(game_node)

# Draw a line connecting 2 nodes
func draw_conn_line(n1, n2):
	# Determine centerpoints of each node
	var loc1x = graph_data[str(n1)]["loc"][0] * get_viewport().size.x
	var loc1y = graph_data[str(n1)]["loc"][1] * get_viewport().size.y
	var loc1 = Vector2(loc1x, loc1y)
	var loc2x = graph_data[str(n2)]["loc"][0] * get_viewport().size.x
	var loc2y = graph_data[str(n2)]["loc"][1] * get_viewport().size.y
	var loc2 = Vector2(loc2x, loc2y)
	# Draw line between given nodes
	var line = Line2D.new()
	line.add_point(loc1)
	line.add_point(loc2)
	match int(globals.pers_opts["skin"]):
		1:
			line.default_color = globals.LIGHT_GREY
		_:
			line.default_color = globals.BLACK
	# Add line to scene and lines group
	call_deferred("add_child", line)
	line.add_to_group("ui_lines")

# Check whether the player has solved the puzzle
func check_win_condition():
	# Check the value of each node, should be non-negative
	for node in graph_data.keys():
		if graph_data[node]["value"] < 0:
			return false
	# If the function hasn't returned yet, all nodes passed check
	get_parent().open_next_puzzle()
