extends Node

# Debug mode
const DEBUG = false

# File operations
const FileIO = preload("res://scripts/file_io.gd")

# Constant file paths
const USER_FILEPATH = "user://user.dat"
const OPTS_FILEPATH = "user://opts.dat"

# Colors for UI
const LIGHT_GREEN = Color("#F000FF00")
const LIGHT_RED = Color("#F0FF0000")
const LIGHT_GREY = Color("#F0A0A0A0")
const BLACK = Color("#FF000000")
const BACK_LIGHT = Color("#FFD8D8D8")
const BACK_DARK = Color("#FF5B5B5B")

# Signal emitted when player gets a new best score
signal player_record

# Global variable
var number_of_levels = -1

# User data file to hold high scores and times
var user_data;

# Options file to keep persistent options
var opts_data;

# Initialization
func _ready():
	
	# Load user data from file
	if File.new().file_exists(USER_FILEPATH):
		user_data = FileIO.read_json_file(USER_FILEPATH)
	else:
		user_data = {}
		FileIO.write_json_file(USER_FILEPATH, user_data)
	
	# Load options data from file
	if File.new().file_exists(OPTS_FILEPATH):
		opts_data = FileIO.read_json_file(OPTS_FILEPATH)
	else:
		# Write default values
		opts_data = {"theme":0, "diff":0, "last":0, "tut":false}
		FileIO.write_json_file(OPTS_FILEPATH, opts_data)
	
	number_of_levels = count_files("res://levels")
	
	# Increase font size on mobile
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		var font = load("res://assets/fonts/roundedelegance.tres")
		font.size *= 1.2

# Global functions

func update_last_level(level):
	
	opts_data["last"] = level
	FileIO.write_json_file(OPTS_FILEPATH, opts_data)

func reload_user_data():
	
	opts_data = FileIO.read_json_file(OPTS_FILEPATH)
	user_data = FileIO.read_json_file(USER_FILEPATH)

# Check if current win beats previous best, and save it if so
func record_win(score, time):
	
	# Get last played level and current difficulty level
	var level = str(opts_data["last"])
	var diff = str(opts_data["diff"])
	
	# If no previous best exists, write a new one
	if !user_data.has(level):
		user_data[level] = {}
		user_data[level][diff] = {"score":score, "time":time}
		FileIO.write_json_file(USER_FILEPATH, user_data)
	
	# If no previous record exists for current difficulty, write one
	elif !user_data[level].has(diff):
		user_data[level][diff] = {"score":score, "time":time}
		FileIO.write_json_file(USER_FILEPATH, user_data)
	
	# If score beats record best, overwrite it
	elif score < user_data[level][diff]["score"]:
		user_data[level][diff]["score"] = score
		user_data[level][diff]["time"] = time
		FileIO.write_json_file(USER_FILEPATH, user_data)
		emit_signal("player_record")
	
	# If score ties and time beats record best, overwrite it
	elif score == user_data[level][diff]["score"] and time < user_data[level][diff]["time"]:
		user_data[level][diff]["time"] = time
		FileIO.write_json_file(USER_FILEPATH, user_data)
		emit_signal("player_record")

# Count the number of files in a given directory
func count_files(path):
	
	var count = 0
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
