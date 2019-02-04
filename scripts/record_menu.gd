extends Node

# UI Elements
onready var rec_list_ui = $"scroll_list/vbox"

# List entry layout
var record_container

func _ready():
	
	# Reload the user data file to make sure we have the latest scores
	globals.reload_user_data()
	
	# Load the container that holds each record's scores and times
	record_container = ResourceLoader.load("res://scenes/record_container.tscn")
	populate_list()

# Populates the list of records
func populate_list():
	
	for record in globals.user_data.keys():
		# Create a new container for this record
		var new_cont = record_container.instance()
		new_cont.init(record)
		rec_list_ui.add_child(new_cont)
