extends Popup

# Utility classes
var RNG = preload("res://scripts/rng_seed.gd")

# UI elements
onready var edit = $"vbox/hbox/edit"
onready var conf_btn = $"vbox/hbox/confirm_btn"

func _ready():
	
	set_process_input(true)
	
	# Set button texture based on theme
	match int(globals.opts_data["theme"]):
		1:
			conf_btn.texture_normal = load("res://assets/icons/accept_dark.png")
		_:
			conf_btn.texture_normal = load("res://assets/icons/accept_light.png")

func open_level():
	
	# If edit is not blank, use contents as RNG seed
	if edit.text != "":
		globals.opts_data["last"] = edit.text
		RNG.set_seed(edit.text)
	else:
		globals.opts_data["last"] = RNG.gen_seed()
	
	# Load instance of game scene
	self.queue_free()
	var level_scene = ResourceLoader.load("res://scenes/game.tscn")
	get_tree().get_root().add_child(level_scene.instance())
