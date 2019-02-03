extends Node

# Subscenes
const RandPopup = preload("res://scenes/rand_popup.tscn")

# GUI objects
onready var lvl_list = get_node("lvl_list")
onready var tuts_btn = get_node("tuts_button")
onready var rand_btn = get_node("rand_button")

func _ready():
	
	populate_list()
	
	lvl_list.connect("item_selected", self, "open_level")
	tuts_btn.connect("pressed", self, "open_tutorials")
	rand_btn.connect("pressed", self, "random_level")

func populate_list():
	
	# Create an item in the list for each level
	for index in range(globals.number_of_levels):
		lvl_list.add_item(str(index + 1))

func open_level(num):
	
	globals.update_last_level(num + 1)
	get_tree().change_scene("res://scenes/game.tscn")

func open_tutorials():
	
	get_tree().change_scene("res://scenes/tutorial.tscn")

func random_level():
	
	# Create a popup to let user enter seed if wanted
	var popup = RandPopup.instance()
	add_child(popup)
	popup.popup_centered_ratio(0.25)
