extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d = $Camera2D

# Exporting for easy testing. Convert back to consts once the movement is locked
@export var max_speed: float = 300.0
@export var max_jump_velocity: float = -600.0
# @export var max_health: float = 100.0
# @export var health_decay_amount: float = 1
# @export var health_decay_interval: float = 1
@export var look_ahead_distance_px: int = 0
# var current_health: float = max_health
var current_speed: float = max_speed
var current_jump_velocity: float = max_jump_velocity
var camera_ease_curve: Curve = preload("res://Assets/Other/player_camera_ease.tres")
var direction: float = 0.0
var jumping: bool = false
var camera_offset_amount: float = 0.0
var camera_move_done: bool = false
var alive: bool = true


func _physics_process(delta):
	if alive:
		apply_gravity(delta)
		process_input()
		move_and_slide()
		look_ahead(delta)
		# get_hungry(delta)
	else:
		# Replace with a call to our Game Over logic
		visible = false


func apply_gravity(delta) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if jumping == true:
			jumping = false
			animated_sprite_2d.play("idle")


func process_input() -> void:
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = current_jump_velocity
		jumping = true
		animated_sprite_2d.play("jump")
	
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * current_speed
		# Flip the sprite to face the direction of movement
		if direction > 0:
			animated_sprite_2d.set_flip_h(false)
		else:
			animated_sprite_2d.set_flip_h(true)
		# Only play the move animation when not jumping
		if not jumping:
			animated_sprite_2d.play("move")
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		# Only play this animation when on the floor
		if not jumping:
			animated_sprite_2d.play("idle")


var curve_sample_pos: float = 0.0
func look_ahead(delta) -> void:
	if not camera_move_done:
		if curve_sample_pos < 1:
			curve_sample_pos += delta
			if curve_sample_pos > 1:
				curve_sample_pos = 1
				camera_move_done = true
			if direction > 0:
				camera_offset_amount += camera_ease_curve.sample(curve_sample_pos)
			elif direction < 0:
				camera_offset_amount -= camera_ease_curve.sample(curve_sample_pos)
		else:
			curve_sample_pos = 0


# var time_passed: float = 0.0
# func get_hungry(delta) -> void:
# 	time_passed += delta
# 	if time_passed >= health_decay_interval:
# 		add_health(-health_decay_amount)
# 		update_player_speed()
# 		time_passed = 0


# func add_health(health_increase: float) -> void:
# 	prints("Health before:", current_health)
# 	current_health += health_increase
# 	if current_health > 100:
# 		current_health = 100
# 	elif current_health <= 0:
# 		current_health = 0
# 		alive = false
# 	prints("Health after:", current_health)


# func update_player_speed() -> void:
# 	#region: Big if statement
# 	if current_health > max_health * 0.9:
# 		animated_sprite_2d.speed_scale = 1
# 		current_speed = max_speed
# 		current_jump_velocity = max_jump_velocity
# 	elif current_health <= max_health * 0.9 and current_health > max_health * 0.8:
# 		animated_sprite_2d.speed_scale = 0.9
# 		current_speed = max_speed * 0.9
# 		current_jump_velocity = max_jump_velocity * 0.9
# 	elif current_health <= max_health * 0.8 and current_health > max_health * 0.7:
# 		animated_sprite_2d.speed_scale = 0.85
# 		current_speed = max_speed * 0.85
# 		current_jump_velocity = max_jump_velocity * 0.85
# 	elif current_health <= max_health * 0.7 and current_health > max_health * 0.6:
# 		animated_sprite_2d.speed_scale = 0.5
# 		current_speed = max_speed * 0.8
# 		current_jump_velocity = max_jump_velocity * 0.8
# 	elif current_health <= max_health * 0.6 and current_health > max_health * 0.5:
# 		animated_sprite_2d.speed_scale = 0.75
# 		current_speed = max_speed * 0.75
# 		current_jump_velocity = max_jump_velocity * 0.75
# 	elif current_health <= max_health * 0.5 and current_health > max_health * 0.4:
# 		animated_sprite_2d.speed_scale = 0.7
# 		current_speed = max_speed * 0.7
# 		current_jump_velocity = max_jump_velocity * 0.7
# 	elif current_health <= max_health * 0.4 and current_health > max_health * 0.3:
# 		animated_sprite_2d.speed_scale = 0.65
# 		current_speed = max_speed * 0.65
# 		current_jump_velocity = max_jump_velocity * 0.65
# 	elif current_health <= max_health * 0.3 and current_health > max_health * 0.2:
# 		animated_sprite_2d.speed_scale = 0.6
# 		current_speed = max_speed * 0.6
# 		current_jump_velocity = max_jump_velocity * 0.6
# 	elif current_health <= max_health * 0.2 and current_health > max_health * 0.1:
# 		animated_sprite_2d.speed_scale = 0.55
# 		current_speed = max_speed * 0.55
# 		current_jump_velocity = max_jump_velocity * 0.55
# 	elif current_health <= max_health * 0.1 and current_health > 0.0:
# 		animated_sprite_2d.speed_scale = 0.5
# 		current_speed = max_speed * 0.5
# 		current_jump_velocity = max_jump_velocity * 0.5
# 	#endregion
