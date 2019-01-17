extends Node

# Utility classes
const FileIO = preload("res://scripts/file_io.gd")
const RNG = preload("res://scripts/rng_seed.gd")

# Subscenes
const RandPopup = preload("res://scenes/rand_popup.tscn")

# GUI objects
onready var lvl_list = get_node("lvl_list")
onready var tuts_btn = get_node("tuts_button")
onready var rand_btn = get_node("rand_button")

func _ready():
	# Populate the list with levels
	populate_list()
	# Connect list to function that opens levels
	lvl_list.connect("item_selected", self, "open_level")
	# Connect tuts button to open_tutorials function
	tuts_btn.connect("pressed", self, "open_tutorials")
	# Connect random button to function that generates a random level
	rand_btn.connect("pressed", self, "random_level")

func populate_list():
	# Create an item in the list for each one
	for index in range(globals.number_of_levels):
		lvl_list.add_item(str(index+1))

func open_level(num):
	# Set level to selected
	globals.update_last_level(num+1)
	# Load instance of game scene
	var level_scene = ResourceLoader.load("res://scenes/game.tscn")
	get_tree().get_root().add_child(level_scene.instance())

func open_tutorials():
	# Load the tutorial scene
	get_tree().change_scene("res://scenes/tutorial.tscn")

func random_level():
	# Create a popup to let user enter seed or not
	var popup = RandPopup.instance()
	add_child(popup)
	popup.popup_centered_ratio(0.25)
