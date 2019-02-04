extends Node

# This class implements the simulated annealing algorithm for graph drawing
# described in Davidson and Harel's paper, "Drawing Graphs Nicely"
# https://dl.acm.org/citation.cfm?id=234538
# https://en.wikipedia.org/wiki/Simulated_annealing

# Constants

# This normalizing factor defines the importance of nodes being clustered 
# together, reducing distances between them.  It is lambda_1 in the paper.
const L1 = 38
# This normalizing factor defines how much nodes are pushed away from the edges
# of the drawing plane.  It is lambda_2 in the paper.
const L2 = 4
# This normalzing factor penalizes long edges between nodes.  It's lambda_3 in
# the paper.
const L3 = 20
# This normalizing factor penalizes close and crossed edges.  It's lambda_4 in
# the paper.
const L4 = 10
# The max number of trials to run before updating global temperature
const TRIALS = 250
# The number of loops to run while fine-tuning the graph
const FINE_TUNING_LOOPS = 750
# The cooling rate for global temperature
const D_TEMP = 0.85
# The temperature threshold for stopping
const LIM_TEMP = 0.35
# The rejection threshold for breaking out of loop
const LIM_REJECT = 50
# The scaling factor used to ajdust the exponential probability function,
# represented by k in the paper and Boltzmann's constant in reality
const PROB_CONST = 0.001
# These establish the borders of the region that nodes can be placed
const BORDER_L = 0.05
const BORDER_R = 0.95
const BORDER_T = 0.2
const BORDER_B = 0.85

# Functions

# Simulated annealing function -- randomly move nodes over time to reduce cost
# function of whole graph
static func annealing(graph):
	
	# Start by randomly distributing all nodes
	for node in graph.keys():
		graph[node]["loc"] = [randf(), randf()]
	
	# Define a starting "temperature", which limits how far nodes can move 
	var temp = 0.85
	
	# Create a counter for how often sequential layouts are rejected
	var rejects = 0
	
	var cost_current = cost(graph, false)
	
	# While temp is above stopping threshold...
	while temp > LIM_TEMP:
		
		# For the predefined number of trials...
		for index in range(TRIALS):
			
			var graph_new = generate_candidate(graph, temp)
			# Calculate the probability of new layout replacing old one.  If new layout
			# has lower cost, replacement is guaranteed
			var cost_new = cost(graph_new, false)
			var prob = exp(-(cost_new - cost_current) * PROB_CONST / temp)
			if randf() < prob:
				print("Old, new, prob: %.2f, %.2f, %s" % [cost_current, cost_new, str(prob)])
				graph = graph_new
				cost_current = cost_new
				rejects = 0
			
			# Otherwise, increment the rejection counter
			else:
				rejects += 1
			
				# If rejection counter is too high, break out of this loop
				if rejects >= LIM_REJECT:
					rejects = 0
					print("Breaking after %d loops..." % index)
					break
		
		# Reduce temperature at a predefined rate
		temp *= D_TEMP
	
	# Once main processing is done, do fine tuning
	var tuning_counter = 0
	temp = 0.08
	for index in range(FINE_TUNING_LOOPS):
		var graph_new = generate_candidate(graph, temp)
		
		# Only replace graph if cost is lower
		var cost_new = cost(graph_new, true)
		if cost_current < cost_new:
			tuning_counter += 1
			graph = graph_new
			cost_current = cost_new
	tuning_counter /= float(FINE_TUNING_LOOPS)
	print("Fine tuning changes: %.4f" % tuning_counter)
	
	return center(graph)

# Helper function to generate a new 'candidate' graph
static func generate_candidate(graph, temp):
	
	# Create a "candidate" graph and modify one node randomly
	var graph_new = graph.duplicate()
	var node = str(randi() % len(graph))
	
	# Move node by taking a vector with temp length, rotating it around the
	# origin by a random angle (up to 2Pi), then adding it to the original loc
	var loc = Vector2(graph[node]["loc"][0], graph[node]["loc"][1])
	var loc_new = Vector2(0, temp).rotated(randf() * 2 * PI) + loc
	
	# Make sure new location is inside bounding box
	loc_new.x = clamp(loc_new.x, BORDER_L, BORDER_R)
	loc_new.y = clamp(loc_new.y, BORDER_T, BORDER_B)
	
	graph_new[node]["loc"] = [loc_new.x, loc_new.y]
	
	return graph_new

# Cost function -- measure of how "good" the current layout is
# Fine_tuning is a boolean representing whether or not the annealing is in the
# fine-tuning phase
static func cost(graph, fine_tuning):
	
	# Total cost of graph -- This could have been one int, but separating them
	# make debugging easier
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
				costs[0] += L1 / node_loc.distance_squared_to(pair_loc)
		
		# BORDER DISTANCE
		# Calculate distance squared to top, bottom, left, and right edges
		var t = max(node_loc.distance_squared_to(Vector2(node_loc.y, BORDER_T)), 0.0001)
		var b = max(node_loc.distance_squared_to(Vector2(node_loc.y, BORDER_B)), 0.0001)
		var l = max(node_loc.distance_squared_to(Vector2(node_loc.x, BORDER_L)), 0.0001)
		var r = max(node_loc.distance_squared_to(Vector2(node_loc.x, BORDER_R)), 0.0001)
		# Add inverses of these vars to total, scaled by l2
		# Small distances mean high cost
		costs[1] += L2 * (1.0 / t + 1.0 / b + 1.0 / l + 1.0 / r)
		
		# For each connection that node has...
		for conn in graph[node]["conns"]:
			# EDGE LENGTHS
			# Add the square distance between the connected nodes
			# Large distances mean high cost
			var conn_loc = Vector2(graph[str(conn)]["loc"][0], graph[str(conn)]["loc"][1])
			var edge_len = node_loc.distance_squared_to(conn_loc)
			costs[2] += L3 * edge_len
			
		if fine_tuning:
			# NODE-EDGE DISTANCES
			# Adaped from this SA answer: https://stackoverflow.com/questions/849211/
			# For each connection in the graph...
			for u in other_nodes:
				for v in graph[u]["conns"]:
					
					# Ignore connection if it includes node
					if node == str(v):
						continue
					
					# Determine the length of the edge squared (with a preset minimum)
					var u_loc = Vector2(graph[u]["loc"][0], graph[u]["loc"][1])
					var v_loc = Vector2(graph[str(v)]["loc"][0], graph[str(v)]["loc"][1])
					var edge_len2 = max(u_loc.distance_squared_to(v_loc), 0.0001)
					
					# Determine where this edge's projection meets a perpendicular projection
					# through node, clamped to keep closest point inside edge
					t = clamp((node_loc - u_loc).dot(v_loc - u_loc) / edge_len2, 0, 1)
					var intersect = u_loc + (t * (v_loc - u_loc))
					
					# Add inverse of the squared distance to total, using a set minimum
					costs[3] += L4 / max(intersect.distance_squared_to(node_loc), 0.0001)
	
	return costs[0] + costs[1] + costs[2] + costs[3]

# Function to center the graph in the viewing window
static func center(graph):
	
	var max_t = 1.0
	var max_b = 0.0
	var max_l = 1.0
	var max_r = 0.0
	
	# Cycle through all nodes to find the closest to each edge
	for node in graph.keys():
		max_t = min(graph[node]["loc"][1], max_t)
		max_b = max(graph[node]["loc"][1], max_b)
		max_l = min(graph[node]["loc"][0], max_l)
		max_r = max(graph[node]["loc"][0], max_r)
		
	# Calculate necessary shifts
	var shift_h = (1.0 - max_l - max_r) / 2.0
	var shift_v = (1.15 - max_b - max_t) / 2.0
	
	# Add shifts onto each node coordinates
	for node in graph.keys():
		graph[node]["loc"][0] += shift_h
		graph[node]["loc"][1] += shift_v
	
	return graph
