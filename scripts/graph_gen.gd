extends Node

# Generate a random graph
static func generate_graph_data():
	# Generate a number of nodes between 5 and 12, inclusive
	var num_nodes = 5 + (randi() % 7)
	# Create a dictionary with that many nodes
	var data = {}
	for index in range(num_nodes):
		data[index] = {"conns":[],"loc":[0.0,0.0],"value":0}
	# Generate a spanning tree to ensure that the graph is connected
	data = generate_tree(data)
	# Add additional connections
	for index in range(randi()%num_nodes):
		data = add_conn(data)

# Assign edges to an empty graph so that it has a spanning tree
static func generate_tree(graph_data):
	# Start with a list of nodes that haven't been connected to yet
	var list = []
	for index in range(len(graph_data)):
		list.append(index)
	# Create a connection for each
	while list.size() > 0:
		# Pick a node at random
		var val1 = randi() % len(graph_data)
		# Pick a second node from the list
		var val2 = randi() % list.size()
		var node = list[val2]
		# If the numbers are different...
		if val1 != node:
			# Remove the node from the list
			list.remove(val2)
			# And add that connection to graph_data
			graph_data[val1]["conns"].append(node)
			graph_data[node]["conns"].append(val1)
	# Return the graph
	return graph_data

# Adds a new, random connection to a given graph
static func add_conn(graph_data):
	# Pick 2 random nodes
	var num1 = randi() % num_nodes
	var num2 = randi() % num_nodes
	# Make sure they're different
	while num1 == num2:
		num2 = randi() % num_nodes
	# Check if that connection already exists
	if graph_data[num1]["conns"].has(num2):
		# Try again
		graph_data = add_conn(graph_data)
	else:
		# Add that connection
		graph_data[num1]["conns"].append(num2)
		graph_data[num2]["conns"].append(num1)
	return graph_data
