extends Node

func _ready():
	var num_tests = 1
	for index in range(num_tests):
		funcref(self, "graph_test_%02d"%(index+1))

### GameGraph Class Tests ###
func graph_test_01():
	print("Running graph_test_01...")
	var graph = GameGraph.new(1)
	assert(len(graph.graph_data) == 3)
	assert(graph.graph_data["1"]["value"] == 2)
	print("Test 01 passed!")

func graph_test_02():
	return
