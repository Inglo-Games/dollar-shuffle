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
		var seed_str = RNG.set_seed(edit.text)
		globals.opts_data["last"] = seed_str
	else:
		globals.opts_data["last"] = RNG.gen_seed()
	
	# Load game scene
	self.queue_free()
	get_tree().change_scene("res://scenes/game.tscn")
