class_name Level
extends Node

@onready var bg_music = get_tree().get_first_node_in_group("BGMusic")
var level_name: String = ""
var left_level_bound: int = 0
var right_level_bound: int = 0
var upper_level_bound: int = 0
var lower_level_bound: int = 0

func start_bg_music():
	bg_music.play()
