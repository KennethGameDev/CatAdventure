extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d = $Camera2D

# Exporting for easy testing. Convert back to consts once the movement is locked
@export var speed: float = 300.0
@export var jump_velocity: float = -600.0
@export var look_ahead_distance_px: int = 0
@export var camera_ease_curve: Curve
var health: float = 100.0
var direction: float = 0.0
var jumping: bool = false
var camera_offset_amount: float = 0.0
var camera_move_done: bool = false


func _physics_process(delta):
	apply_gravity(delta)
	
	process_input()
	
	move_and_slide()
	
	look_ahead(delta)


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
		velocity.y = jump_velocity
		jumping = true
		animated_sprite_2d.play("jump")
	
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
		# Flip the sprite to face the direction of movement
		if direction > 0:
			animated_sprite_2d.set_flip_h(false)
		else:
			animated_sprite_2d.set_flip_h(true)
		# Only play the move animation when not jumping
		# BUG: the walking animation will continue when walking off a ledge because that is not a "jump"
		# Solution: the flag should be changed from "jumping" to "airborne" and be set to true whenever
		# our cat is not on the floor
		if not jumping:
			animated_sprite_2d.play("move")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
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
