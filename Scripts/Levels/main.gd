extends Node2D

@export var camera_lead_speed: float = 0.5
@onready var camera = $Camera2D
var player_scene: PackedScene = preload("res://Scenes/Player/cat.tscn")
var player: CharacterBody2D = null
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

func _physics_process(delta):
	if current_level_name != "StartMenu":
		# Handle pausing.
		if Input.is_action_just_released("pause"):
			ui.pause_button_pressed()
	
	camera_follow(delta)

func change_level(level_index: int) -> Array:
	if level_index >= 0 and level_index < level_scenes.size():
		if startup_complete:
			ui.fade_to_black()
			await get_tree().create_timer(1).timeout
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
		if level_index != 0:
			ui.show_hud_only()
			initialize_player()
		get_tree().paused = false
		if current_level.bg_music:
			current_level.start_bg_music()
		ui.fade_out_from_black()
		await get_tree().create_timer(1).timeout
		return [true, "Level successfully changed from " + prev_level_name + " to " + current_level_name]
	else:
		return [false, "Level change failed.\nProvided index outside the level_scenes array bounds (0-" + str(level_scenes.size()) + ")."]

func initialize_ui() -> void:
	ui = ui_scene.instantiate()
	get_child(0).get_child(0).add_child(ui)
	ui.scale = Vector2(0.5, 0.5)
	ui.position = Vector2(ui.size.x / 4, ui.size.y / 4)

func initialize_player() -> void:
	var spawn_location: Vector2
	for child in current_level.get_children():
		if child.name == "Level Start":
			spawn_location = child.global_position
	player = player_scene.instantiate()
	player.health_decay_amount = 10
	player.health_decay_interval = 0.5
	current_level.add_child(player)
	player.position = spawn_location

func camera_follow(delta):
	if player:
		if player.direction > 0:
			camera.position.x = move_toward(camera.position.x, player.camera_look_ahead.global_position.x, delta * player.current_speed + camera_lead_speed)
			camera.position.y = move_toward(camera.position.y, player.camera_look_ahead.global_position.y, delta * -player.current_jump_velocity + camera_lead_speed)
		elif player.direction < 0:
			camera.position.x = move_toward(camera.position.x, player.camera_look_behind.global_position.x, delta * player.current_speed + camera_lead_speed)
			camera.position.y = move_toward(camera.position.y, player.camera_look_behind.global_position.y, delta * -player.current_jump_velocity + camera_lead_speed)
		else:
			camera.position.x = move_toward(camera.position.x, player.camera_follow_point.global_position.x, delta * player.current_speed)
			camera.position.y = move_toward(camera.position.y, player.camera_follow_point.global_position.y, delta * -player.current_jump_velocity)
