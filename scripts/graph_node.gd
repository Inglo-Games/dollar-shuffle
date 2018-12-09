extends Control

# Sizes for node UI, initialized to large values
var scale_val = 100.0

# Node number this instance represents
var node_num = -1

# UI elements
var sprite
var label
var pos_node_img
var neg_node_img

func _ready():
	# Add sprite to show node image
	sprite = Sprite.new()
	call_deferred("add_child", sprite)
	sprite.set_texture(load("res://assets/icons/dot_red_light.png"))
	# Set node images depending on dark mode
	if globals.pers_opts["darkmode"]:
		pos_node_img = load("res://assets/icons/dot_green_dark.png")
		neg_node_img = load("res://assets/icons/dot_red_dark.png")
	else:
		pos_node_img = load("res://assets/icons/dot_green_light.png")
		neg_node_img = load("res://assets/icons/dot_red_light.png")
	# Set scale of texture based on given size
	var scale_ratio = scale_val / 100.0
	sprite.scale = Vector2(scale_ratio, scale_ratio)
	# Set control node's size and position to match texture
	self.rect_size = sprite.texture.get_size()
	# Add label showing current value
	label = Label.new()
	call_deferred("add_child", label)
	# Allow input
	set_process_input(true)
	connect("gui_input", self, "handle_node_click")

# Custom draw function
func _draw():
	# Determine image to use based on value
	var value = get_parent().get_parent().graph.graph_data[str(node_num)]["value"]
	if value < 0:
		sprite.set_texture(neg_node_img)
	else:
		sprite.set_texture(pos_node_img)
	# Set text of label to value
	label.text = "$%d" % value
	label.align = Label.ALIGN_CENTER
	# Position label in center of circle
	var label_size = label.get_minimum_size()
	label.rect_position = Vector2(-label_size.x/2.0, -label_size.y/2.0)

# Handle inputs
func handle_node_click(event):
	# Consider it handled
	accept_event()
	# Only inputs are give action and take action
	if event.is_action_released("give_action"):
		get_parent().get_parent().node_give_points(node_num)
	elif event.is_action_released("take_action"):
		get_parent().get_parent().node_take_points(node_num)

# Custom init function
func initialize(num, size):
	# Save node number being represented
	node_num = num
	# Set scale size
	scale_val = size
