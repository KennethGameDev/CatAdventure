extends Node2D

var ui_scene: PackedScene = preload("res://Scenes/UI/ui.tscn")
var ui: UI = null
var level_scenes: Array[PackedScene] = [preload("res://Scenes/Levels/start_menu.tscn"), preload("res://Scenes/Levels/zone_1.tscn"), preload("res://Scenes/Levels/zone_2.tscn")]
var current_level: Level = null
var current_level_name: String = ""
var prev_level_name: String = ""
var startup_complete: bool = false

func _ready():
	initialize_ui()
	change_level(0)
	await ui.fade_out_from_black()
	startup_complete = true

func change_level(level_index: int) -> Array:
	if level_index >= 0 and level_index < level_scenes.size():
		if startup_complete:
			await ui.fade_to_black()
			get_tree().paused = true
			if level_scenes[level_index]:
				prev_level_name = current_level_name
				get_tree().get_first_node_in_group("Level").queue_free()
			else:
				return [false, "Level change failed.\nCould not find any level at index " + str(level_index)]
			current_level.queue_free()
		current_level = level_scenes[level_index].instantiate()
		add_child(current_level)
		move_child(current_level, 0)
		current_level_name = current_level.level_name
		await ui.fade_out_from_black()
		get_tree().paused = false
		return [true, "Level successfully changed from " + prev_level_name + " to " + current_level_name]
	else:
		return [false, "Level change failed.\nProvided index outside the level_scenes array bounds (0-" + str(level_scenes.size()) + ")."]

func initialize_ui() -> void:
	ui = ui_scene.instantiate()
	get_child(0).add_child(ui)
