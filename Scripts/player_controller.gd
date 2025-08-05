extends CharacterBody2D

# Exporting for easy testing. Convert back to consts once the movement is locked
@export var speed: float = 300.0
@export var jump_velocity: float = -600.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d = $Camera2D
var jumping: bool = false


func _physics_process(delta):
	apply_gravity(delta)
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		jumping = true
		animated_sprite_2d.play("jump")
	
	process_movement_input()
	
	# NOT FUNCTIONAL YET
	attempt_climb(delta)
	# NOT FUNCTIONAL YET
	attempt_mantle(delta)
	
	move_and_slide()

func apply_gravity(delta) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if jumping == true:
			jumping = false
			animated_sprite_2d.play("idle")

func process_movement_input() -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
		# Flip the sprite to face the direction of movement
		if direction > 0:
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.flip_h = true
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

func attempt_mantle(delta) -> void:
	if is_on_wall():
		# If the cat's front paws can reach a ledge, it can pull itself up.
		# So, if the cat's sprite is a certain amount higher than the ledge when it collides with a wall
		# it will be pushed up and onto the ledge, simulating a mantle.
		# We will need:
			# The position at the top of the cat's sprite.
			# The positions of the tiles the cat is colliding with.
			# The position of the "ledge" (top corner of the platform).
		pass

func attempt_climb(delta) -> void:
	if is_on_wall():
		# Similar to mantling, but we don't care about the cat's height.
		# If the cat is touching a climbable wall it sticks to that wall and slowly climbs
		pass

# Testing for the wall detection. Doesn't seem helpful yet...
func _on_area_2d_body_entered(body):
	print(body.get_collision_layer())
