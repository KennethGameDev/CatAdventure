extends Node2D

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
@export var oscilation_height: float = 6.0
@export var oscilation_speed_mult: float = 5.0
var new_oscilation_speed: float = 1.0
var oscilation_timer: float = 0.0
var max_height: float = 0.0
var count_up: bool = true
var starting_pos: Vector2
var rng = RandomNumberGenerator.new()

func _ready():
	starting_pos = global_position
	oscilation_timer = rng.randf_range(0.0, oscilation_height)
	if oscilation_timer > 1 and oscilation_timer < oscilation_height - 1:
		new_oscilation_speed = oscilation_speed_mult

func _physics_process(delta):
	#region: Floating "animation" code 
	# When the item reaches the top,
	if oscilation_timer > oscilation_height:
		# Set the timer to the upper limit,
		oscilation_timer = oscilation_height
		# Record the max height reached,
		max_height = position.y
		# Set the timer to count down.
		count_up = false
	# When the item reaches the bottom,
	if oscilation_timer < 0:
		# Set the timer to the lower limit,
		oscilation_timer = 0
		# Set the timer to count up.
		count_up = true
	# If counting up,
	if count_up:
		# As the item is leaving the lower limit,
		if oscilation_timer < 1:
			# Gradually increase the speed to the limit,
			# (the ease() function lets me approximate a smooth curve, and returns a float between 0-1)
			# (this one counts forward)
			new_oscilation_speed = oscilation_speed_mult * (1 + ease(oscilation_timer, -0.5))
			# If it goes past the upper speed limit, set it to that limit.
			if new_oscilation_speed > oscilation_speed_mult:
				new_oscilation_speed = oscilation_speed_mult
		# As the item approaches the upper limit,
		elif oscilation_timer > oscilation_height - 1:
			# Gradually reduce the speed to 1 ('oscilation_timer' becomes 'oscilation_timer - (oscilation_height - 1)'),
			# (this one counts backward)
			new_oscilation_speed = oscilation_speed_mult * (1 - ease(oscilation_timer - (oscilation_height - 1), -0.5))
			# If it goes past 1, set it back to 1.
			if new_oscilation_speed < 1:
				new_oscilation_speed = 1
		# Increase the timer by the time between frames (delta) times the item's current speed.
		oscilation_timer += delta * new_oscilation_speed
		# Icrease the item's height.
		position.y = starting_pos.y - oscilation_timer
	# If counting down,
	else:
		# As the item approaches the lower limit,
		if oscilation_timer < 1:
			# Gradually reduce the speed to 1,
			# (count backward)
			new_oscilation_speed = oscilation_speed_mult * (1 - ease(oscilation_timer - (oscilation_height - 1), -0.5))
			# If it goes past 1, set it back to 1.
			if new_oscilation_speed < 1:
				new_oscilation_speed = 1
		# As the item is leaving the upper limit,
		elif oscilation_timer > oscilation_height - 1:
			# Gradually increase the speed to the limit,
			# (count forward)
			new_oscilation_speed = oscilation_speed_mult * (1 + ease(oscilation_timer, -0.5))
			# If it goes past the upper speed limit, set it to that limit.
			if new_oscilation_speed > oscilation_speed_mult:
				new_oscilation_speed = oscilation_speed_mult
		# Increase the timer by the time between frames (delta) times the item's current speed.
		oscilation_timer -= delta * new_oscilation_speed
		# Descrease the item's height
		position.y = max_height + (oscilation_height - oscilation_timer)
	#endregion

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		player.add_health(20)
	queue_free()
