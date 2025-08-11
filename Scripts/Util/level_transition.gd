extends Node2D

@onready var main: Node2D = get_tree().get_first_node_in_group("Main")
@export var next_level_index: int = 0


func _on_area_2d_body_entered(body: Node2D):
	if body.is_class("CharacterBody2D"):
		if next_level_index >= 0 and next_level_index < main.level_scenes.size():
			main.change_level(next_level_index)
		if next_level_index == 4:
			main.ui.fade_to_black()
			await get_tree().create_timer(1).timeout
			main.ui.roll_credits()
		else:
			push_error("Level index not found. Level change not attempted.")
