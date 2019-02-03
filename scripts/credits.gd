extends Node

onready var vid_btn = get_node("vid_btn")

func _ready():
	
	vid_btn.connect("pressed", self, "open_video")

func open_video():
	
	OS.shell_open("https://www.youtube.com/watch?v=U33dsEcKgeQ")
