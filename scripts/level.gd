extends Node2D

# UI Elements
onready var timer = get_node("timer")
onready var score = get_node("score")
onready var undo_btn = get_node("undo_btn")
onready var pause_btn = get_node("pause_btn")

# Load the GameGraph classes
const GameGraph = preload("res://scripts/graph.gd")
const GameNode = preload("res://scripts/graph_node.gd")

# GameGraph object for this level
onready var graph

# Colors for node UI
const LIGHT_GREEN = Color("#F000FF00")
const LIGHT_RED = Color("#F0FF0000")
const LIGHT_GREY = Color("#F0A0A0A0")
const BLACK = Color("#FF000000")

# Size for node UI
var radius = 100.0

# Time elapsed in milliseconds
var secs = 0.0

# List of moves as Vector2s, where x is the node tapped and y is whether it gave or took
# 1 means gave points, -1 means took points
var moves = []

# List of each node's Area2D representation
var node_areas = []

# Puzzle number to load in
var puzzle = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Entering level._ready function...")
	# Load in level from file
	graph = GameGraph.new()
	# Set size of nodes on screen
	calc_radius()
	# Draw everything on screen
	display_graph()
	score.text = "0"

# Called every frame
func _process(delta):
	# Update timer
	secs += delta
	timer.text = str("%.3f" % secs)

# Set node radii sizes based on number of nodes
func calc_radius():
	# Calculate outer_radius
	radius = 80.0 / log(len(graph.graph_data))

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
		# Create an Area2D to hold sprite and collision shape
		node_areas.append(Area2D.new())
		draw_node(index)

# Draw a single node on the screen
func draw_node(num):
	# Get node from GameGraph
	var node = node_areas[num]
	# Convert location to pixel coords
	var location = Vector2(0,0)
	location.x = graph.graph_data[str(num)]["loc"][0] * get_viewport().size.x
	location.y = graph.graph_data[str(num)]["loc"][1] * get_viewport().size.y
	# DEBUG
	print("Drawing circle at %s" % str(location))
	# Create GameNode object to add to screen
	var game_node = GameNode.new()
	game_node.initialize(self, num, radius)
	game_node.position = location
	get_parent().call_deferred("add_child", game_node)

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
	line.default_color = BLACK
	get_parent().call_deferred("add_child", line)

# Callback for tapping on node
func node_tap(node):
	# Give points to all neighbors
	graph.give_points(node)
	# Record move
	moves.append(Vector2(node, 1))
	# Update moves label
	score.text = str(len(moves))

# Callback for long pressing on node
func node_longpress(node):
	# Take points from all neighbors
	graph.give_points(node)
	# Record move
	moves.append(Vector2(node, -1))
	# Update moves label
	score.text = str(len(moves))

# Undo last move
func undo():
	# Take last move from list
	var move = moves[-1]
	# Do opposite of last move to same node
	if (move.y == -1):
		graph.give_points(abs(move.x))
	else:
		graph.take_points(move.x)
	# Remove last 2 moves (since we just added another one)
	moves.remove(-1)
	moves.remove(-1)
