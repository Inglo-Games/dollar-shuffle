extends Node

# File operations
const FileIO = preload("res://scripts/file_io.gd")

# Constant file paths
const opts_filepath = "user://opts.dat"
const user_filepath = "user://user.dat"

# Global variables
var current_level = 1
var number_of_levels = -1
var pers_opts;

# Initialization
func _ready():
	# Load options data from file (if it exists)
	if File.new().file_exists(opts_filepath):
		pers_opts = FileIO.read_json_file(opts_filepath)
	else:
		pers_opts = get_options_defaults()
	pass
	# Load user data from file
	if File.new().file_exists(user_filepath):
		var user_data = FileIO.read_json_file(user_filepath)
		current_level = user_data["last_played"]
	# Get number of levels in res://levels directory
	number_of_levels = count_files("res://levels")

# Global functions

# Return options defalts
func get_options_defaults():
	return { "difficulty":0, "darkmode":false }

# Update the last played level saved to userdata file
func update_last_level(num):
	# Update variable and write to file
	current_level = num
	FileIO.write_json_file(user_filepath, {"last_played":current_level})

# Change current puzzle to next puzzle
func open_next_puzzle(scene):
	# Make sure that puzzle exists
	if current_level + 1 > number_of_levels:
		# Return to main menu
		scene.queue_free()
		get_tree().change_scene("res://scenes/main_menu.tscn")
		return
	# Else, increment level num and load new game scene
	current_level += 1
	update_last_level(current_level)
	scene.queue_free()
	scene = ResourceLoader.load("res://scenes/game.tscn")
	get_tree().get_root().add_child(scene.instance())

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
		if !file.begins_with("."):
			count += 1
		file = dir.get_next()
	return count
