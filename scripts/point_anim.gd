extends Sprite

# Speed the point should move
const percent_per_sec = 1.45

# Distance to destination before dissapating
const limit_dist = 128.0

# Node locations
var loc_start = Vector2(0, 0)
var loc_end = Vector2(0, 0)

# Percentage moved
var dist_moved = 0.0

func _ready():
	
	set_process(true)
	
	# Setup texture and center it
	texture = load("res://assets/icons/dollar.png")
	centered = true
	show_behind_parent = true
	visible = false

func _process(delta):
	
	# Clear node if it reached its end location
	var dist = loc_end.distance_to(position)
	if dist < limit_dist * scale.x:
		visible = false
		queue_free()
	
	# Else move it closer to destination node
	else:
		dist_moved += delta * percent_per_sec
		position = loc_start.linear_interpolate(loc_end, dist_moved)
		visible = true

func init(node1, node2):
	
	# Save the start and end locations
	loc_start = node1.rect_position + (node1.rect_size * node1.rect_scale * 0.5)
	loc_end = node2.rect_position + (node2.rect_size * node2.rect_scale * 0.5)
