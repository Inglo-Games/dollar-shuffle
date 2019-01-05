extends Node

# Generate a random graph
static func generate_graph_data():
	# Generate a number of nodes between 5 and 12, inclusive
	var num_nodes = 5 + (randi() % 8)
	# Create a dictionary with that many nodes
	var data = {}
	for index in range(num_nodes):
		data[str(index)] = {"conns":[],"loc":[0.5,0.5],"value":-2}
	# Generate a spanning tree to ensure that the graph is connected
	data = generate_tree(data)
	# Add additional connections
	for index in range(randi() % num_nodes):
		data = add_conn(data)
	# Distribute points at random
	data = distribute_points(data)
	# Setup node layout
	data = organize_nodes(data)
	# Debug print
	print("New graph: %s" % str(data))
	return data

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
			graph_data[str(val1)]["conns"].append(node)
			graph_data[str(node)]["conns"].append(val1)
	# Return the graph
	return graph_data

# Adds a new, random connection to a given graph
static func add_conn(graph_data):
	var n = len(graph_data)
	# Pick 2 random nodes
	var num1 = randi() % n
	var num2 = randi() % n
	# Make sure they're different
	while num1 == num2:
		num2 = randi() % n
	# Check if that connection already exists
	if graph_data[str(num1)]["conns"].has(num2):
		# Try again
		graph_data = add_conn(graph_data)
	else:
		# Add that connection
		graph_data[str(num1)]["conns"].append(num2)
		graph_data[str(num2)]["conns"].append(num1)
	return graph_data

# Distribute the nodes evenly around the board
static func organize_nodes(graph_data):
	var n = len(graph_data)
	# For each node in the graph...
	for node in graph_data.keys():
		# Easy solution: circle around center
		var rot = 2 * PI * float(node) / n
		# Scale down circle coords and center on [0.5,0.5]
		var x = cos(rot) * 0.35 + 0.5
		var y = sin(rot) * 0.35 + 0.5
		graph_data[str(node)]["loc"] = [x, y]
	return graph_data

# Distribute points randomly until graph is solvable
static func distribute_points(graph_data):
	var n = graph_data.size()
	# Calculate the minimum number of points needed based on genus
	var conns = 0
	for node in graph_data.keys():
		conns += graph_data[node].size()
	conns /= 2
	var min_points = conns - n + 1
	# Start with current total value, noting each node is initialized with -2 val
	var total = n * -2
	# Add points at random until total equals min_points
	while max(min_points, 0) > total:
		graph_data[str(randi()%n)]["value"] += 1
		total += 1
	return graph_data
