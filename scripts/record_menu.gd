extends Node

# UI Elements
onready var back_btn = get_node("back_btn")
onready var rec_list_ui = get_node("scroll_list/v_cont")

# List entry layout
var record_container

# Called on load
func _ready():
	# Set background color and back button if dark mode
	if globals.pers_opts["darkmode"]:
		get_node("background").color = globals.BACK_DARK
		back_btn.texture_normal = load("res://assets/icons/back_dark.png")
	# Load the container that holds each record's scores and times
	record_container = ResourceLoader.load("res://scenes/record_container.tscn")
	populate_list()
	# Connect back button to close function
	back_btn.connect("pressed", self, "close_menu")

# Populates the list of records
func populate_list():
	# Iterate through list of records
	for record in globals.user_data.keys():
		# Skip current_level entry
		if record != "last_played":
			# Create a new container for this record
			var new_cont = record_container.instance()
			# Fill in labels
			var recs = globals.user_data[record]
			new_cont.get_node("level_id").text = record
			if(recs.has("0")):
				new_cont.get_node("nums/easy_rec").text = "Easy:         %d (%.3f)" % recs["0"].values()
			if(recs.has("1")):
				new_cont.get_node("nums/med_rec").text = "Medium:  %d (%.3f)" % recs["1"].values()
			if(recs.has("2")):
				new_cont.get_node("nums/hard_rec").text = "Hard:         %d (%.3f)" % recs["2"].values()
			# Add new container to view
			rec_list_ui.add_child(new_cont)

func close_menu():
	# Return to main menu
	get_tree().change_scene("res://scenes/main_menu.tscn")
