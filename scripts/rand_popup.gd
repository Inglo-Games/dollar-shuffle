extends Popup

# Utility classes
var RNG = preload("res://scripts/rng_seed.gd")

# UI elements
onready var edit = get_node("vbox/hbox/edit")
onready var conf_btn = get_node("vbox/hbox/confirm_btn")

func _ready():
	set_process_input(true)
	# Connect button to its function
	conf_btn.connect("pressed", self, "open_level")

func open_level():
	# If edit is not blank, use contents as RNG seed
	if edit.text != "":
		ProjectSettings.set("game/last_played", edit.text)
		RNG.set_seed(edit.text)
	else:
		ProjectSettings.set("game/last_played", RNG.gen_seed())
	# Free this popup from memory
	self.queue_free()
	# Load instance of game scene
	var level_scene = ResourceLoader.load("res://scenes/game.tscn")
	get_tree().get_root().add_child(level_scene.instance())
