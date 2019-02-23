extends Node

# Preload the random layout code
const Layout = preload("res://scripts/graph_annealing.gd")

# Preload the RNG seeding code
const RNG = preload("res://scripts/rng_seed.gd")

# Generate a random graph
static func generate_graph_data():
	
	var diff = int(globals.opts_data["diff"])
	
	# Reset seed so same graph gets produced every time
	RNG.set_seed(globals.opts_data["last"])
	
	# Generate a number of nodes, high difficulty means more
	var num_nodes = 8 + (randi() % 4) * diff
	
	# Create a dictionary with that many nodes
	var data = {}
	for index in range(num_nodes):
		data[index] = {"conns":[], "loc":Vector2(0.5, 0.5), "value":-2}
	
	data = generate_tree(data)
	
	# Add additional connections
	for index in range(randi() % (num_nodes * diff + 1) + (num_nodes / 2)):
		data = add_conn(data)
		
	data = distribute_points(data)
	data = Layout.annealing(data)
	
	# Debug print
	#print("Graph seed: %s" % globals.opts_data["last"])
	#print("New graph: %s" % str(data))
	
	return data

# Assign edges to an empty graph so that it has a spanning tree without any
# duplicate edges
static func generate_tree(graph_data):
	
	# Start with a list of nodes that haven't been connected to yet
	# containing all nodes except one
	var out_list = []
	for index in range(len(graph_data) - 1):
		out_list.append(index)
	
	# Also create a list of nodes that *have* been connected,
	# containing the one node left out of the other list
	var in_list = [len(graph_data) - 1]
	
	# Create a connection for each unconnected node
	while out_list.size() > 0:
		
		# Pick one node from each list
		var node1 = in_list[randi() % in_list.size()]
		var node2 = out_list[randi() % out_list.size()]
		
		# Remove node2 from the out_list and add it to the in_list
		out_list.erase(node2)
		in_list.append(node2)
		
		# And add that connection to graph_data
		graph_data[node1]["conns"].append(node2)
		graph_data[node2]["conns"].append(node1)
		
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
	if graph_data[num1]["conns"].has(num2):
		# Try again
		# TODO -- There's got to be a more elegant way to do this...
		graph_data = add_conn(graph_data)
		
	else:
		# Add that connection
		graph_data[num1]["conns"].append(num2)
		graph_data[num2]["conns"].append(num1)
	
	return graph_data

# Distribute points randomly until graph is solvable
static func distribute_points(graph_data):
	
	var n = len(graph_data)
	
	# Calculate the minimum number of points needed based on genus
	var conns = 0
	for node in graph_data.keys():
		conns += graph_data[node]["conns"].size() * 0.5
	var min_points = conns - n + 1
	
	# Add more points on easier difficulties
	min_points += (2 - int(globals.opts_data["diff"])) * (randi() % 2 + 1)
	
	# Start with current total value, noting each node is initialized with -2 val
	var total = n * -2
	
	# Create a list of nodes to add to
	var whitelist = []
	for index in range(n):
		whitelist.append(index)
	
	# Remove 2-4 nodes from that list at random
	# This guarantees some negative nodes
	for index in range((randi() % 3) + 3):
		whitelist.remove(randi() % whitelist.size())
	
	# Add points at random until total equals min_points
	while min_points > total:
		# Either add 1 or subtract 1 from a random node, with a 25% chance of 
		# subtracting
		var point = 1
		if randf() <= 0.25:
			point = -1
			
		# Pick the node to add to/sub from
		var target = whitelist[randi() % whitelist.size()]
		graph_data[target]["value"] += point
		total += point
	
	return graph_data
