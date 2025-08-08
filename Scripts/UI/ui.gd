class_name UI
extends Control

var main: Node2D

func _ready():
	main = get_tree().get_first_node_in_group("Main")
