# This is a utility class to handle file operations
extends Node

static func read_json_file(path):
	
	var file = File.new()
	
	# Error checking -- ensure file exists and can be opened
	if !file.file_exists(path):
		# TODO: Implement popup message for nonexistent file
		print("File doesn't exist...")
		return
	if file.open(path, file.READ) != OK:
		# TODO: Implement popup message for bad read
		print("Could not read file...")
		return
	
	# Read in the file contents and parse it
	var parsed_json = JSON.parse(file.get_as_text())
	file.close()
	if parsed_json.error != OK:
		# TODO: Implement popup message for bad JSON parse
		print("Could not parse JSON...")
		return
	
	return parsed_json.result

static func write_json_file(path, data):
	
	var file = File.new()
	if file.open(path, file.WRITE) != OK:
		# TODO: Implement popup message for bad open
		print("Could not read file...")
		return
	# Write data and close connection
	file.store_line(to_json(data))
	file.close()
