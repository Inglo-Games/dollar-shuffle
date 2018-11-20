extends Button

# Get base node
onready var base_node = get_node("/base")

func _ready():
	connect("pressed", base_node, "toggle_pause", [])
