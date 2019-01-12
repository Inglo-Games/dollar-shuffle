extends Node

# Debug mode
const debug = false

# File operations
const FileIO = preload("res://scripts/file_io.gd")

# Constant file paths
const opts_filepath = "user://opts.dat"
const user_filepath = "user://user.dat"

# Colors for UI
const LIGHT_GREEN = Color("#F000FF00")
const LIGHT_RED = Color("#F0FF0000")
const LIGHT_GREY = Color("#F0A0A0A0")
const BLACK = Color("#FF000000")
const BACK_LIGHT = Color("#FFD8D8D8")
const BACK_DARK = Color("#FF5B5B5B")

# Global variables
var current_level = 1
var number_of_levels = -1

# User data file to hold high scores and times
var user_data;

# Initialization
func _ready():
	# Write game-specific options to project config if they're not already there
	if !ProjectSettings.has_setting("gui/theme/skin"):
		var info = {
			"name":"gui/theme/skin",
			"type":TYPE_INT,
			"hint":PROPERTY_HINT_ENUM,
			"hint_string":"zero,one"
		}
		ProjectSettings.set("gui/theme/skin", 0)
		ProjectSettings.add_property_info(info)
	if !ProjectSettings.has_setting("game/difficulty"):
		var info = {
			"name":"game/difficulty",
			"type":TYPE_INT,
			"hint":PROPERTY_HINT_ENUM,
			"hint_string":"zero,one,two"
		}
		ProjectSettings.set("game/difficulty", 0)
		ProjectSettings.add_property_info(info)
	if !ProjectSettings.has_setting("game/last_played"):
		var info = {
			"name":"game/last_played",
			"type":TYPE_OBJECT,
			"hint":PROPERTY_HINT_NONE,
			"hint_string":""
		}
		ProjectSettings.set("game/last_played", 1)
		ProjectSettings.add_property_info(info)
	if !ProjectSettings.has_setting("game/tutorial_played"):
		var info = {
			"name":"game/tutorial_played",
			"type":TYPE_BOOL,
			"hint":PROPERTY_HINT_ENUM,
			"hint_string":"true,false"
		}
		ProjectSettings.set("game/tutorial_played", false)
		ProjectSettings.add_property_info(info)
	ProjectSettings.save()
	# Set current level
	current_level = ProjectSettings.get_setting("game/last_played")
	# Load user data from file
	if File.new().file_exists(user_filepath):
		user_data = FileIO.read_json_file(user_filepath)
	else:
		user_data = {}
		FileIO.write_json_file(user_filepath, user_data)
	# Get number of levels in res://levels directory
	number_of_levels = count_files("res://levels")

# Global functions

# Update the last played level saved to userdata file
func update_last_level():
	# Update variable and write to file
	ProjectSettings.set("game/last_played", current_level)
	ProjectSettings.save()

# Check if current win beats previous best, and save it if so
func record_win(score, time):
	# Get current difficulty level
	var diff = ProjectSettings.get_setting("game/difficulty")
	# If no previous best exists, write a new one
	if !user_data.has(globals.current_level):
		user_data[globals.current_level] = {}
		user_data[globals.current_level][diff] = {"score":score,"time":time}
		FileIO.write_json_file(user_filepath, user_data)
	# If no previous record exists for current difficulty, write one
	elif !user_data[globals.current_level].has(diff):
		user_data[globals.current_level][diff] = {"score":score,"time":time}
		FileIO.write_json_file(user_filepath, user_data)
	# If score beats record best, overwrite it
	elif score < user_data[globals.current_level][diff]["score"]:
		user_data[globals.current_level][diff]["score"] = score
		user_data[globals.current_level][diff]["time"] = time
		FileIO.write_json_file(user_filepath, user_data)
	# If score ties and time beats record best, overwrite it
	elif score == user_data[globals.current_level][diff]["score"] and time < user_data[globals.current_level][diff]["time"]:
		user_data[globals.current_level][diff]["time"] = time
		FileIO.write_json_file(user_filepath, user_data)

# Count the number of files in a given directory
func count_files(path):
	var count = 0
	# Open given directory
	var dir = Directory.new()
	dir.open(path)
	# Cycle through files
	dir.list_dir_begin()
	var file = dir.get_next()
	while(file != ""):
		# Only count non-directory files
		if file.ends_with(".json"):
			count += 1
		file = dir.get_next()
	return count
