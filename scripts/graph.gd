# This represents the graph (nodes and connections) for each puzzle
extends Node

# Get file IO functions
const FileIO = preload("res://scripts/file_io.gd")

# Dictionary containing all graph data
var graph_data = {}

# Constructor function, takes number corresponding to current puzzle
func _init():
	# Get number of level to load
	var lvl_num = globals.current_level
	# Open the file describing the level
	var filepath = "res://levels/%03d.json" % lvl_num
	graph_data = FileIO.read_json_file(filepath)

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
