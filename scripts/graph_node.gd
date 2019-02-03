extends Control

# Time separating long and short press in seconds
const press_threshold = 0.6

# Node number this instance represents
var node_num = -1

# Keep track of how long a button press is
var press_time = 0

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
	match int(globals.opts_data["theme"]):
		# Dark mode
		1:
			pos_node_img = load("res://assets/icons/dot_green_dark.png")
			neg_node_img = load("res://assets/icons/dot_red_dark.png")
		# Colorblind (Deuteranopia) mode
		2:
			pos_node_img = load("res://assets/icons/dot_blue_deut.png")
			neg_node_img = load("res://assets/icons/dot_orng_deut.png")
		# Everything else, including light mode
		_:
			pos_node_img = load("res://assets/icons/dot_green_light.png")
			neg_node_img = load("res://assets/icons/dot_red_light.png")
	
	# Add label showing current value
	label = Label.new()
	label.rect_scale = Vector2(2, 2)
	call_deferred("add_child", label)
	
	# Allow input
	set_process_input(true)
	connect("gui_input", self, "handle_node_click")

# Custom draw function
func _draw():
	
	# Determine image to use based on value
	var value = get_parent().get_parent().graph_data[str(node_num)]["value"]
	if value < 0:
		sprite.set_texture(neg_node_img)
	else:
		sprite.set_texture(pos_node_img)
	
	sprite.centered = false	
	
	# Set text of label to value
	label.text = "$%d" % value
	label.align = Label.ALIGN_CENTER
	
	# Position label in center of circle
	label.rect_position = -label.get_minimum_size() + sprite.texture.get_size() / 2.0

# Automatic process function
func _process(delta):
	
	# Check if node is being long pressed and add to time var
	if Input.is_action_pressed("leftclick_action"):
		press_time += delta
	else:
		press_time = 0

# Handle inputs
func handle_node_click(event):
	
	# Handle left clicks/touchscreen touches
	if event.is_action_released("leftclick_action"):
		
		# Result depends on length of click
		if press_time < press_threshold:
			# Short press means give points
			get_parent().get_parent().give_points(node_num)
		else:
			# Long press means take points
			get_parent().get_parent().take_points(node_num)
		
		# Reset press time either way
		press_time = 0
	
	# Handle right clicks
	elif event.is_action_released("rightclick_action"):
		get_parent().get_parent().take_points(node_num)

func initialize(num):
	
	# Save node number being represented
	node_num = num
