class_name Level
extends Node

@onready var bg_music = get_tree().get_first_node_in_group("BGMusic")
var level_name: String = ""

func start_bg_music():
	bg_music.play()
