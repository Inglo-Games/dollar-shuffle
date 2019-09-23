extends Control

# UI Elements
onready var backg = $bg_layer/background
onready var graph = $node_ui_container
onready var timer = $ui_layer/label_container/timer
onready var score = $ui_layer/label_container/score
onready var undo_btn = $ui_layer/btn_container/undo_btn
onready var pause_btn = $ui_layer/btn_container/pause_btn
onready var record_label = $ui_layer/record_label
onready var pause_bg = $ui_layer/pause_background
onready var animation = $anim

# Load the GameGraph classes
const GameGraph = preload("res://scripts/graph.gd")

# Load utility classes
const RNG = preload("res://scripts/rng_seed.gd")

# Preload pause menu
const PausePopup = preload("res://scenes/pause_popup.tscn")

# Time elapsed in seconds and active boolean
var secs = 0.0
var timer_active = true

# Number of undos left
var undos_remaining = INF

# List of moves as Vector2s, where x is the node tapped and y is whether it gave or took
# 1 means gave points, -1 means took points
var moves = []

func _ready():
	
	# Set background color and buttons based on theme
	match int(globals.opts_data["theme"]):
		1:
			theme = load("res://assets/dark.theme")
			backg.color = globals.BACK_DARK
			undo_btn.texture_normal = load("res://assets/icons/undo_dark.png")
			undo_btn.texture_disabled = load("res://assets/icons/undo_disabled_dark.png")
			pause_btn.texture_normal = load("res://assets/icons/pause_dark.png")
		_:
			theme = load("res://assets/light.theme")
			backg.color = globals.BACK_LIGHT
			undo_btn.texture_normal = load("res://assets/icons/undo_light.png")
			undo_btn.texture_disabled = load("res://assets/icons/undo_disabled_light.png")
			pause_btn.texture_normal = load("res://assets/icons/pause_light.png")
	
	# Load in level from file
	graph.load_puzzle(globals.opts_data["last"])
	
	# Draw everything on screen
	graph.display_graph()
	score.text = "0"
	
	globals.connect("player_record", self, "show_record")
	
	reset_undos()

# Called every frame
func _process(delta):
	
	# Update timer, if active
	if timer_active:
		secs += delta
		timer.text = str("%.3f" % secs)

# Clear the old graph and load a new one
func transition_graph():
	
	# First, clear out old graph
	animation.queue("fadeout")
	yield(animation, "animation_finished")
	for container in graph.get_children():
		for ui in container.get_children():
			ui.queue_free()
	graph.load_puzzle(globals.opts_data["last"])
	
	# Reset score, timer, and undos
	moves = []
	score.text = "0"
	secs = 0.0
	timer.text = str("%.3f" % secs)
	record_label.rect_position = Vector2(0, -70)
	reset_undos()
	
	graph.display_graph()
	
	# Fade display back in
	animation.play("fadein")
	yield(animation, "animation_finished")
	
	# Restart timer
	timer_active = true

# Set the number of undos remaining based on difficulty
func reset_undos():
	
	match int(globals.opts_data["diff"]):
		0:
			undos_remaining = INF
			undo_btn.disabled = false
		1:
			undos_remaining = 3
			undo_btn.disabled = false
		2:
			undos_remaining = 0
			undo_btn.disabled = true

# Function to update score label
func update_score():
	
	score.text = str(len(moves))

# Change current puzzle to next puzzle
func open_next_puzzle():
	
	var level = globals.opts_data["last"]
	
	timer_active = false
	globals.record_win(len(moves), secs)
	
	# If this is a randomly generated level...
	if typeof(level) == TYPE_STRING:
		globals.update_last_level(RNG.gen_seed())
		transition_graph()
	
	# If this is a pre-made level...
	elif typeof(level) == TYPE_INT:
	
		# Make sure the next level exists
		if level + 1 > globals.number_of_levels:
			# Return to main menu if it doesn't
			self.queue_free()
			get_tree().change_scene("res://scenes/menu_frame.tscn")
			return
		
		# Increment level num and load new level
		globals.update_last_level(level + 1)
		transition_graph()

# Show the new-record label and play audio
func show_record():
	
	$record_audio.play()
	animation.play("record_prompt")

# Undo last move
func undo():
	
	# Only do if moves have been done and user has undos left
	if len(moves) > 0 and undos_remaining > 0:
		
		var move = moves[-1]
		
		# Do opposite of last move to same node
		if (move.y == -1):
			graph.give_points(int(move.x))
		else:
			graph.take_points(int(move.x))
		
		# Wait for point moving animations to play out
		undo_btn.disabled = true
		yield(get_tree().create_timer(0.6), "timeout")
		undo_btn.disabled = false
		
		# Remove last 2 moves (since we just added another one)
		moves.remove(len(moves)-1)
		moves.remove(len(moves)-1)
		score.text = str(len(moves))
		
		undos_remaining -= 1
		
		# If no undos remain, disable undo button
		if undos_remaining == 0:
			undo_btn.disabled = true

# Pause game
func toggle_pause():
	
	# Make the obscuring background layer visible
	pause_bg.visible = true
	
	# Create and show pause menu
	var popup = PausePopup.instance()
	$ui_layer.add_child(popup)
	popup.popup_centered()
	get_tree().set_pause(true)
