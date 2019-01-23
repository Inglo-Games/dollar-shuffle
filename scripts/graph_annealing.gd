extends Node

# This class implements the simulated annealing algorithm for graph drawing
# described in Davidson and Harel's paper, "Drawing Graphs Nicely"
# https://dl.acm.org/citation.cfm?id=234538
# https://en.wikipedia.org/wiki/Simulated_annealing

# Constants

# This normalizing factor defines the importance of nodes being clustered 
# together, reducing distances between them.  It is lambda_1 in the paper.
const l1 = 0.5
# This normalizing factor defines how much nodes are pushed away from the edges
# of the drawing plane.  It is lambda_2 in the paper.
const l2 = 0.1
# This normalzing factor penalizes long edges between nodes.  It's lambda_3 in
# the paper.
const l3 = 500
# This normalizing factor penalizes close and crossed edges.  It's lambda_4 in
# the paper.
const l4 = 50
# The max number of trials to run before updating global temperature
const trials = 250
# The number of loops to run while fine-tuning the graph
const fine_tuning_loops = 1000
# The cooling rate for global temperature
const d_temp = 0.85
# The temperature threshold for stopping
const lim_temp = 0.05
# The scaling factor used to ajdust the exponential probability function,
# represented by k in the paper and Boltzmann's constant in reality
const prob_const = 0.00001

# Functions

# Simulated annealing function -- randomly move nodes over time to reduce cost
# function of whole graph
static func annealing(graph):
	# Start by randomly distributing all nodes
	for node in graph.keys():
		graph[node]["loc"] = [randf(), randf()]
	# Define a starting "temperature", which limits how far nodes can move 
	var temp = 0.4
	# Create a counter for how often sequential layouts are rejected
	var rejects = 0
	# Calculate current cost of whole system
	var cost_current = cost(graph, false)
	# While temp is above stopping threshold...
	while temp > lim_temp:
		# For the predefined number of trials...
		for index in range(trials):
			# Create a new "candidate" graph
			var graph_new = generate_candidate(graph, temp)
			# Calculate the probability of new layout replacing old one.  If new layout
			# has lower cost, replacement is guaranteed
			var cost_new = cost(graph_new, false)
			var prob = exp(-(cost_new - cost_current) * prob_const / temp)
			print("Old, new, prob: %.2f, %.2f, %s" % [cost_current, cost_new, str(prob)])
			if randf() < prob:
				graph = graph_new
				cost_current = cost_new
				rejects = 0
			# Otherwise, increment the rejection counter
			else:
				rejects += 1
				# If rejection counter is too high, break out of this loop
				if rejects > 10:
					rejects = 0
					break
		# Reduce temperature at a predefined rate
		temp *= d_temp
	
	# Once main processing is done, do fine tuning
	for index in range(fine_tuning_loops):
		var graph_new = generate_candidate(graph, temp)
		# Only replace graph if cost is lower
		var cost_new = cost(graph_new, true)
		if cost_current < cost_new:
			graph = graph_new
			cost_current = cost_new
	
	# Return the new graph
	return graph

# Helper function to generate a new 'candidate' graph
static func generate_candidate(graph, temp):
	# Create a "candidate" graph and modify every node randomly
	var graph_new = graph.duplicate()
	for node in graph_new.keys():
		# Move node by taking a vector with temp length, rotating it around the
		# origin by a random angle (up to 2Pi), then adding it to the original loc
		var loc = Vector2(graph[node]["loc"][0], graph[node]["loc"][1])
		var loc_new = Vector2(0, temp).rotated(randf()*2*PI) + loc
		# Make sure new location is inside bounding box
		loc_new.x = clamp(loc_new.x, 0.1, 0.9)
		loc_new.y = clamp(loc_new.y, 0.1, 0.9)
		# Save new location in candidate graph
		graph_new[node]["loc"] = [loc_new.x, loc_new.y]
	# Return the new graph
	return graph_new


# Cost function -- measure of how "good" the current layout is
# Fine_tuning is a boolean representing whether or not the annealing is in the
# fine-tuning phase
static func cost(graph, fine_tuning):
	# Total cost of graph
	var costs = [0, 0, 0, 0]
	# For each node in the graph...
	for node in graph.keys():
		# Get location of current node
		var node_loc = Vector2(graph[node]["loc"][0], graph[node]["loc"][1])

		# NODE DISTRIBUTION 
		# For each pair of nodes in graph...
		var other_nodes = graph.keys()
		other_nodes.erase(node)
		for pair in other_nodes:
			# Add the square inverse of nodes' distance
			# Small distance means high cost
			var pair_loc = Vector2(graph[pair]["loc"][0], graph[pair]["loc"][1])
			if node_loc.distance_squared_to(pair_loc) == 0:
				costs[0] += INF
				break
			else:
				costs[0] += l1 / node_loc.distance_squared_to(pair_loc)
		
		# BORDER DISTANCE
		# Calculate distance squared to top, bottom, left, and right edges
		var t = max(node_loc.distance_squared_to(Vector2(node_loc.x, 0)), 0.05)
		var b = max(node_loc.distance_squared_to(Vector2(node_loc.x, 1)), 0.05)
		var l = max(node_loc.distance_squared_to(Vector2(0, node_loc.y)), 0.05)
		var r = max(node_loc.distance_squared_to(Vector2(1, node_loc.y)), 0.05)
		# Add inverses of these vars to total, scaled by l2
		# Small distances mean high cost
		costs[1] += l2 * (1.0/t + 1.0/b + 1.0/l + 1.0/r)
		
		# For each connection that node has...
		for conn in graph[node]["conns"]:
			
			# EDGE LENGTHS
			# Add the square distance between the connected nodes
			# Large distances mean high cost
			var conn_loc = Vector2(graph[str(conn)]["loc"][0], graph[str(conn)]["loc"][1])
			var edge_len = node_loc.distance_squared_to(conn_loc)
			costs[2] += l3 * edge_len
			
			if fine_tuning:
				# NODE-EDGE DISTANCES
				# For each node other than the two connected...
				other_nodes.erase(str(conn))
				for other in other_nodes:
					# Get location of 'other'
					var other_loc = Vector2(graph[other]["loc"][0], graph[other]["loc"][1])
					# Determine where this edge's projection meets a perpendicular projection
					# through 'other', clamped to keep closest point inside edge
					edge_len = max(edge_len, 0.01)
					t = clamp((other_loc - node_loc).dot(conn_loc - node_loc) / edge_len, 0, 1)
					var projection = node_loc + (t * (conn_loc - node_loc))
					# Add inverse of the squared distance to total, using a set minimum
					costs[3] = l4 / max(projection.distance_squared_to(other_loc), 0.01)
	
	return costs[0]+costs[1]+costs[2]+costs[3]
