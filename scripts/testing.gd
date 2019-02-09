extends Node

const FileIO = preload("res://scripts/file_io.gd")

func _ready():
	
	for index in range(globals.number_of_levels):
		graph_corrupt(index + 1)
		graph_solvable(index + 1)

# Ensure graph connections are legitimate
func graph_corrupt(num):
	
	var corrupt = false
	
	# Load the level file
	var file = File.new()
	file.open("res://levels/%03d.lvl" % num, file.READ)
	var data = file.get_var()
	file.close()
	
	# For each connection to each node...
	for node in data.keys():
		for conn in data[node]["conns"]:
			
			# Make sure node isn't connected to itself
			if conn == node:
				print("Graph %d Error: Node %d connects to self" % [num, conn])
				corrupt = true
			
			# Make sure reciprocal connection exists
			if not (data.has(conn) and data[conn]["conns"].has(node)):
				print("Graph %d Error: One way connection %s to %d" % [num, node, conn])
				corrupt = true
			
	# Otherwise node is OK, do nothing
	return corrupt

# Ensure graph can be solved
func graph_solvable(num):
	
	# Load the level file
	var file = File.new()
	file.open("res://levels/%03d.lvl" % num, file.READ)
	var data = file.get_var()
	file.close()
	
	# Get number of nodes, edges and total value
	var edges = 0
	var total_val = 0
	for node in data:
		edges += len(data[node]["conns"])
		total_val += data[node]["value"]
	edges /= 2
	var nodes = len(data)
	
	# From video, total value must be greater than or equal to 'genus'
	# Not perfect test, but good enough for this
	return total_val >= edges - nodes + 1
