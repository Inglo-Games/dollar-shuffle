extends Node2D

# Colors for node UI
const LIGHT_GREEN = Color("#F000FF00")
const LIGHT_RED = Color("#F0FF0000")
const LIGHT_GREY = Color("#F0A0A0A0")
const BLACK = Color("#FF000000")

# Sizes for node UI, initialized to large values
var outer_radius = 100.0
var inner_radius = 87.0

# Node number this instance represents
var node_num = -1

# Level base node
var parent_node

# UI element
onready var label

func _ready():
	label = Label.new()
	call_deferred("add_child", label)

# Custom draw function
func _draw():
	# Determine color of inner circle based on value
	var value = parent_node.graph.graph_data[str(node_num)]["value"]
	var color = LIGHT_GREEN
	if value < 0:
		color = LIGHT_RED
	# Draw an outer black circle
	draw_circle(
			Vector2(0,0),
			outer_radius,
			BLACK)
	# Draw inner circle
	draw_circle(
			Vector2(0,0),
			inner_radius,
			color)
	# Set text of label to value
	label.text = "$%d" % value
	label.align = Label.ALIGN_CENTER
	# Position label in center of circle
	var label_size = label.get_minimum_size()
	label.rect_position = Vector2(-label_size.x/2.0, -label_size.y/2.0)

# Custom init function
func initialize(parent, num, size):
	# Save parent node to access GameGraph object
	parent_node = parent
	# Save node number being represented
	node_num = num
	# Set radii sizes
	outer_radius = size
	inner_radius = outer_radius * 0.87
