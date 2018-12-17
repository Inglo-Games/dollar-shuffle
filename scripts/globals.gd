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

# Persistent options and user data
var pers_opts;
var user_data;

# Initialization
func _ready():
	# Load options data from file (if it exists)
	if File.new().file_exists(opts_filepath):
		pers_opts = FileIO.read_json_file(opts_filepath)
	else:
		pers_opts = get_options_defaults()
		FileIO.write_json_file(opts_filepath, pers_opts)
	# Load user data from file
	if File.new().file_exists(user_filepath):
		user_data = FileIO.read_json_file(user_filepath)
		current_level = user_data["last_played"]
	else:
		user_data = {"last_played":0}
		FileIO.write_json_file(user_filepath, user_data)
	# Get number of levels in res://levels directory
	number_of_levels = count_files("res://levels")

# Global functions

# Return options defalts
func get_options_defaults():
	return { "difficulty":0, "skin":0 }

# Update the last played level saved to userdata file
func update_last_level(num):
	# Update variable and write to file
	current_level = num
	user_data["last_played"] = num
	FileIO.write_json_file(user_filepath, user_data)

# Check if current win beats previous best, and save it if so
func record_win(score, time):
	# Get current difficulty level
	var diff = pers_opts["difficulty"]
	# If no previous best exists, write a new one
	if !user_data.has(str(current_level)):
		user_data[str(current_level)] = {}
		user_data[str(current_level)][diff] = {"score":score,"time":time}
		FileIO.write_json_file(user_filepath, user_data)
	# If no previous record exists for current difficulty, write one
	elif !user_data[str(current_level)].has(diff):
		user_data[str(current_level)][diff] = {"score":score,"time":time}
		FileIO.write_json_file(user_filepath, user_data)
	# If score beats record best, overwrite it
	elif score < user_data[str(current_level)][diff]["score"]:
		user_data[str(current_level)][diff]["score"] = score
		user_data[str(current_level)][diff]["time"] = time
		FileIO.write_json_file(user_filepath, user_data)
	# If score ties and time beats record best, overwrite it
	elif score == user_data[str(current_level)][diff]["score"] and time < user_data[str(current_level)][diff]["time"]:
		user_data[str(current_level)][diff]["time"] = time
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
