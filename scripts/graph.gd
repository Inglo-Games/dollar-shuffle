# This represents the graph (nodes and connections) for each puzzle
extends Node

# Get file IO functions
const FileIO = preload("res://scripts/file_io.gd")

# Dictionary containing all graph data
var graph_data = {}

func load_puzzle(input):
	# If it's an int, load that level number
	if typeof(input) == TYPE_INT:
		var filepath = "res://levels/%03d.json" % input
		graph_data = FileIO.read_json_file(filepath)
	# If it's the string 'tut', load the tutorials
	elif str(input).matchn('tut1'):
		graph_data = FileIO.read_json_file("res://levels/tuts/1.json")
	elif str(input).matchn('tut2'):
		graph_data = FileIO.read_json_file("res://levels/tuts/2.json")

# Take one point from each neighbor of a given node and add that many to it
func take_points(node):
	# Take one from each neighbor
	for neighbor in graph_data[str(node)]["conns"]:
		graph_data[str(neighbor)]["value"] -= 1
	# Add that many to node
	graph_data[str(node)]["value"] += len(graph_data[str(node)]["conns"])

# Add one point to each neighbor from given node
func give_points(node):
	# Subtract one for each neighbor
	graph_data[str(node)]["value"] -= len(graph_data[str(node)]["conns"])
	# Add one to each neighbor
	for neighbor in graph_data[str(node)]["conns"]:
		graph_data[str(neighbor)]["value"] += 1
