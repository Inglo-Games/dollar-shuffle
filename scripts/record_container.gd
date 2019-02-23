extends Control

# The ID for the level this container shows
var id = ""

# Initialization
func _ready():
	
	# Allow input
	set_process_input(true)
	
	connect("gui_input", self, "record_cont_input")

func init(record):
	
	# Set instance variable so input funcs can access it
	# Remove padding 0s if integer level ID
	if len(record) == 3:
		id = str(int(record))
	else:
		id = record
	
	# Fill in labels
	var recs = globals.user_data[id]
	get_node("level_id").text = "%s" % record
	if(recs.has("0")):
		get_node("nums/easy_rec").text = "Easy:         %d (%.3f)" % recs["0"].values()
	if(recs.has("1")):
		get_node("nums/med_rec").text = "Medium:  %d (%.3f)" % recs["1"].values()
	if(recs.has("2")):
		get_node("nums/hard_rec").text = "Hard:         %d (%.3f)" % recs["2"].values()

# Deal with inputs in the record container
func record_cont_input(event):
	
	if event.is_action_released("leftclick_action"):
		# Create a popup asking if user wants open that level
		var popup = ConfirmationDialog.new()
		popup.get_label().set_text("Open puzzle %s?" % id)
		# Set the affirmative button to open game screen
		popup.get_ok().connect("pressed", self, "open_level")
		# Show popup
		get_parent().add_child(popup)
		popup.popup_centered_minsize()
		
		# Play click sound
		$click.play()

# Open the given level
func open_level():
	
	# Convert ID to int if needed
	if int(id) != 0 and len(id) <= 3:
		id = int(id)
	
	globals.opts_data["last"] = id
	get_tree().change_scene("res://scenes/game.tscn")
