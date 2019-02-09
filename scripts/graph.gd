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

# Containers for lines, animations, and nodes
var line_cont
var anim_cont
var node_cont

# Scale to use for all UI elements
var ui_scale = Vector2(1.0, 1.0)

func load_puzzle(input):
	
	node_list = []
	
	# If it's an int, load that level number
	if typeof(input) == TYPE_INT:
		var filepath = "res://levels/%03d.lvl" % input
		var file = File.new()
		file.open(filepath, file.READ)
		graph_data = file.get_var()
		file.close()
		#var filepath = "res://levels/%03d.json" % input
		#graph_data = FileIO.read_json_file(filepath)
		#globals.save_graph_as_file(int(input), graph_data)
	
	# If it's the string 'tut', load the tutorials
	elif str(input).matchn('tut1'):
		graph_data = FileIO.read_json_file("res://levels/tuts/1.json")
	elif str(input).matchn('tut2'):
		graph_data = FileIO.read_json_file("res://levels/tuts/2.json")
	elif str(input).matchn('tut3'):
		graph_data = FileIO.read_json_file("res://levels/tuts/3.json")
	elif str(input).matchn('tut4'):
		graph_data = FileIO.read_json_file("res://levels/tuts/4.json")
	
	# If it's another string, load a random graph
	elif typeof(input) == TYPE_STRING:
		graph_data = GameGen.generate_graph_data()
	
	# Set the scale value
	ui_scale = Vector2(2.0 / (len(graph_data) + 1), 2.0 / (len(graph_data) + 1))
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		ui_scale *= 1.3
	
	# Create containers for graph elements
	line_cont = Node2D.new()
	call_deferred("add_child", line_cont)
	anim_cont = Node2D.new()
	call_deferred("add_child", anim_cont)
	node_cont = Node2D.new()
	call_deferred("add_child", node_cont)

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
