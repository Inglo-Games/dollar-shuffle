extends TextureButton

# Get base node
onready var base_node = get_node("/root/base")

func _ready():
	connect("pressed", base_node, "toggle_pause", [])
