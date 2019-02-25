extends Node

const level_num = 41

func _ready():
	
	save_graph_as_file(level_num, create_level())

# Define a graph dictionary
func create_level():
	
	# Create new level
	var new_level = {
		0: {"conns":[],
			"loc":Vector2(0.5,0.5),
			"value":0},
			
		1: {"conns":[],
			"loc":Vector2(0.5,0.5),
			"value":0},
			
		2: {"conns":[],
			"loc":Vector2(0.5,0.5),
			"value":0},
			
		3: {"conns":[],
			"loc":Vector2(0.5,0.5),
			"value":0},
			
		4: {"conns":[],
			"loc":Vector2(0.5,0.5),
			"value":0},
			
		5: {"conns":[],
			"loc":Vector2(0.5,0.5),
			"value":0},
	}
	return new_level

# Transform a level dict into a file
func save_graph_as_file(num, dict):
	
	var filepath = "res://levels/%03d.lvl" % num
	var file = File.new()
	file.open(filepath, file.WRITE)
	file.store_var(dict)
	file.close()
