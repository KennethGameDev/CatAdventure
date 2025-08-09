class_name UtilFunctions
extends Node

var ui_scene: PackedScene = preload("res://Scenes/UI/ui.tscn")
var ui: UI = null
var level_scenes: Array[PackedScene] = [preload("res://Scenes/Levels/start_menu.tscn"), preload("res://Scenes/Levels/zone_1.tscn"), preload("res://Scenes/Levels/zone_2.tscn")]
var current_level: Level = null
var current_level_name: String = ""
var prev_level_name: String = ""
var startup_complete: bool = false
signal fade_to_black_sig
signal fade_out_from_black_sig

func _ready():
	change_level(0)
	initialize_ui()
	# Game starts with a black screen,
	# so fade into the main menu after setup is done.
	emit_signal("fade_out_from_black_sig")
	startup_complete = true

func change_level(level_index: int) -> Array:
	if level_index >= 0 and level_index < level_scenes.size():
		if startup_complete:
			emit_signal("fade_to_black_sig")
			if find_child(current_level_name).is_class("Level"):
				prev_level_name = current_level_name
				find_child(current_level_name).queue_free()
			else:
				return [false, "Level change failed.\nCould not find any level at index " + str(level_index)]
		current_level = level_scenes[level_index].instantiate()
		current_level_name = current_level.level_name
		add_child(current_level)
		return [true, "Level successfully changed from " + prev_level_name + " to " + current_level_name]
	else:
		return [false, "Level change failed.\nProvided index outside the level_scenes array bounds (0-" + str(level_scenes.size()) + ")."]

func initialize_ui() -> void:
	ui = ui_scene.instantiate()
	add_child(ui)
	move_child(ui, 0)
	ui.connect("fade_to_black_sig", ui.fade_to_black())
	ui.connect("fade_out_from_black_sig", ui.fade_out_from_black())
