# This represents the graph (nodes and connections) for each puzzle
extends Node

# Dictionary containing all graph data
var graph_data = {}

# Constructor function, takes number corresponding to current puzzle
func _init():
	# DEBUG
	print("Initializing GameGraph structure...")
	var lvl_num = 1
	
	# Open the file describing the level
	var lvl_file = File.new()
	var filepath = "res://levels/%03d.json" % lvl_num
	print("Loading file %s" % filepath)
	
	# Error checking -- ensure file exists and can be opened
	if !lvl_file.file_exists(filepath):
		# TODO: Implement popup message for nonexistent file
		print("File doesn't exist...")
		return
	if lvl_file.open(filepath, lvl_file.READ) != OK:
		# TODO: Implement popup message for bad read
		print("Could not read file...")
		return
	
	# Read in the file contents and parse it
	var parsed_json = JSON.parse(lvl_file.get_as_text())
	lvl_file.close()
	if parsed_json.error != OK:
		# TODO: Implement popup message for bad JSON parse
		print("Could not parse JSON...")
		return
	
	# Save parsed data
	graph_data = parsed_json.result

# Take one point from each neighbor of a given node and add that many to it
func take_points(node):
	# Take one from each neighbor
	for neighbor in graph_data[str(node)]["conns"]:
		graph_data[neighbor]["value"] -= 1
	# Add that many to node
	graph_data[str(node)]["value"] += len(graph_data[str(node)]["conns"])

# Add one point to each neighbor from given node
func give_points(node):
	# Subtract one for each neighbor
	graph_data[str(node)]["value"] -= len(graph_data[str(node)]["conns"])
	# Add one to each neighbor
	for neighbor in graph_data[str(node)]["conns"]:
		graph_data[neighbor]["value"] += 1
