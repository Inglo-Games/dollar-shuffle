extends Node

# UI Elements
onready var rec_list_ui = get_node("scroll_list/vbox")

# List entry layout
var record_container

# Called on load
func _ready():
	# Load the container that holds each record's scores and times
	record_container = ResourceLoader.load("res://scenes/record_container.tscn")
	populate_list()

# Populates the list of records
func populate_list():
	# Iterate through list of records
	for record in globals.user_data.keys():
		# Create a new container for this record
		var new_cont = record_container.instance()
		# Fill in labels
		var recs = globals.user_data[record]
		new_cont.get_node("level_id").text = "%s" % record
		if(recs.has("0")):
			new_cont.get_node("nums/easy_rec").text = "Easy:         %d (%.3f)" % recs["0"].values()
		if(recs.has("1")):
			new_cont.get_node("nums/med_rec").text = "Medium:  %d (%.3f)" % recs["1"].values()
		if(recs.has("2")):
			new_cont.get_node("nums/hard_rec").text = "Hard:         %d (%.3f)" % recs["2"].values()
		# Add new container to view
		rec_list_ui.add_child(new_cont)
