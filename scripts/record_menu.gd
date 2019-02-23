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
	
	for record in sort_records():
		# Create a new container for this record
		var new_cont = record_container.instance()
		new_cont.init(record)
		rec_list_ui.add_child(new_cont)

# Sorts the keys in numeric, the alphabetic order
func sort_records():
	
	var sorted_list = []
	var sorted_dict = {}
	var data = globals.user_data
	
	for record in data.keys():
		# Random level IDs are all at least 6 chars long
		if len(record) >= 6:
			sorted_list.append(record)
		else:
			sorted_list.append("%03d" % int(record))
	
	# Sort the list then construct the dictionary
	sorted_list.sort()
	for record in sorted_list:
		if len(record) >= 6:
			sorted_dict[record] = data[record]
		else:
			sorted_dict[record] = data[str(int(record))]
	
	return sorted_dict
