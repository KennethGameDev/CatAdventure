extends CharacterBody2D

# Exporting for easy testing. Convert back to consts once the movement is locked
@export var speed = 300.0
@export var jump_velocity = -800.0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	attempt_climb(delta)
	attempt_mantle(delta)
	
	move_and_slide()

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


func _on_area_2d_body_entered(body):
	print(body.get_collision_layer())
