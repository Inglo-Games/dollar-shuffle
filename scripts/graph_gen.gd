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
	print("Graph seed: %s" % globals.current_level)
	print("New graph: %s" % str(data))
	return data

# Assign edges to an empty graph so that it has a spanning tree without any
# duplicate edges
static func generate_tree(graph_data):
	# Start with a list of nodes that haven't been connected to yet
	# containing all nodes except one
	var out_list = []
	for index in range(len(graph_data)-1):
		out_list.append(index)
	# Also create a list of nodes that *have* been connected,
	# containing the one node left out of the other list
	var in_list = [len(graph_data)-1]
	# Create a connection for each unconnected node
	while out_list.size() > 0:
		# Pick a node at random from connected nodes
		var node1 = in_list[randi() % in_list.size()]
		# Pick another node at random from the unconnected nodes
		var node2 = out_list[randi() % out_list.size()]
		# Remove node2 from the out_list and add it to the in_list
		out_list.erase(node2)
		in_list.append(node2)
		# And add that connection to graph_data
		graph_data[str(node1)]["conns"].append(node2)
		graph_data[str(node2)]["conns"].append(node1)
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
	var n = len(graph_data)
	# Calculate the minimum number of points needed based on genus
	var conns = 0
	for node in graph_data.keys():
		conns += graph_data[node]["conns"].size() * 0.5
	var min_points = max(conns - n + 1, 0)
	# Start with current total value, noting each node is initialized with -2 val
	var total = n * -2
	# Add points at random until total equals min_points
	while min_points > total:
		# Either add 1 or subtract 1 from a random node, with a 
		# 40% chance of subtracting
		var point = 1
		if randf() <= 0.4:
			point = -1
		graph_data[str(randi()%n)]["value"] += point
		total += point
	return graph_data
