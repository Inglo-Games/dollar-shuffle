extends Control

# Sizes for node UI, initialized to large values
var scale_val = 100.0
var scaled_size = Vector2(100.0, 100.0)

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
	match int(globals.pers_opts["skin"]):
		0:
			pos_node_img = load("res://assets/icons/dot_green_light.png")
			neg_node_img = load("res://assets/icons/dot_red_light.png")
		1:
			pos_node_img = load("res://assets/icons/dot_green_dark.png")
			neg_node_img = load("res://assets/icons/dot_red_dark.png")
		_:
			pos_node_img = load("res://assets/icons/dot_green_light.png")
			neg_node_img = load("res://assets/icons/dot_red_light.png")
	# Set scale of texture based on given size
	var scale_ratio = scale_val / 100.0
	scaled_size = sprite.texture.get_size() * scale_ratio
	sprite.scale = Vector2(scale_ratio, scale_ratio)
	sprite.offset = scaled_size
	# Set control node's size to match texture
	self.rect_size = scaled_size
	# Center control node over current origin
	self.rect_global_position -= scaled_size / 2.0
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
	label.rect_position = Vector2(-label_size.x/2.0, -label_size.y/2.0) + scaled_size/2.0
	# Draw a translucent back for debugging
	if globals.debug:
		var debug_back = ColorRect.new()
		debug_back.rect_position = Vector2(0, 0)
		debug_back.anchor_right = 1.0
		debug_back.anchor_bottom = 1.0
		debug_back.color = Color(1.0, 0.0, 1.0, 0.2)
		debug_back.visible = true
		call_deferred("add_child", debug_back)

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
