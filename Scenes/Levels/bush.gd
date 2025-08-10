extends Area2D

# --- Food scenes to spawn ---
@export var good_food_scene: PackedScene
@export var neutral_food_scene: PackedScene
@export var toxic_food_scene: PackedScene

# --- Behaviour toggles ---
@export var one_shot: bool = true                  # spawn only once then disable
@export var cooldown_seconds: float = 1.0          # used only if one_shot = false

# --- Spawn placement ---
@export var use_spawn_point: bool = true           # use child Marker2D "SpawnPoint" if present
@export var spawn_offset: Vector2 = Vector2.ZERO   # else: bush center + this offset

# --- Fall, bounce, growth (NO overshoot) ---
@export var fall_time_s: float = 0.5               # time to reach ground
@export var max_fall_distance_px: float = 512.0    # ray length downward
@export var bounce_base_is_half_fall: bool = true  # base bounce = half fall height
@export_range(0.0, 1.0, 0.01) var bounce1_frac: float = 0.345   # 15% bouncier than 0.30
@export_range(0.0, 1.0, 0.01) var bounce2_frac: float = 0.1725  # 15% bouncier than 0.15
@export var grow_factor: float = 2.5               # ×2.5 = +150% size
@export var scale_visual_child: bool = true        # scale Sprite2D/AnimatedSprite2D instead of root

# --- Visuals for "spent" bushes ---
@export var fade_when_spent: bool = true
@export var hide_when_spent: bool = false

# --- Prompt (optional child named "Prompt") ---
@export var show_prompt: bool = false
@export var prompt_offset: Vector2 = Vector2(0, -24)

# --- Debug ---
@export var debug_logs: bool = false

# --- Runtime ---
var _player_near: bool = false
var _cooling_down: bool = false
var _can_spawn: bool = true
var _spent: bool = false
var _input_locked: bool = false            # <-- latch so E only works once

# shake cache
var _base_scale: Vector2 = Vector2.ONE
var _shake_tween: Tween

@onready var _prompt: Node = get_node_or_null("Prompt")
@onready var _sprite2d: Sprite2D = get_node_or_null("Sprite2D")
@onready var _anim2d: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

# ---------- helpers used early ----------
func _show_prompt(show: bool) -> void:
	if !show_prompt or _prompt == null:
		return
	_prompt.visible = show

func _set_prompt_local_offset() -> void:
	if _prompt is Node2D:
		(_prompt as Node2D).position = prompt_offset
# ----------------------------------------

func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

	var vis: Node2D = _get_bush_visual()
	if vis != null:
		_base_scale = vis.scale

	if _prompt:
		_prompt.visible = false
		_set_prompt_local_offset()

	randomize()
	if debug_logs:
		print("[Bush] Ready one_shot=", one_shot, " fall_time=", fall_time_s)

func _process(_delta: float) -> void:
	# Latch check blocks any further presses after first trigger
	if _spent or !_can_spawn or _cooling_down or _input_locked:
		return
	if _player_near and Input.is_action_just_pressed("interact"):
		_input_locked = true   # <-- latch immediately
		_try_spawn()

func _on_enter(body: Node) -> void:
	if _spent:
		return
	if body.is_in_group("player"):
		_player_near = true
		_show_prompt(true)
		if debug_logs: print("[Bush] Player entered")

func _on_exit(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
		_show_prompt(false)
		if debug_logs: print("[Bush] Player left")

func _try_spawn() -> void:
	_input_locked = true  # belt-and-braces latch (in case multiple paths fire same frame)
	if _spent or !_can_spawn or _cooling_down:
		return

	var choices: Array[PackedScene] = []
	if good_food_scene != null: choices.append(good_food_scene)
	if neutral_food_scene != null: choices.append(neutral_food_scene)
	if toxic_food_scene != null: choices.append(toxic_food_scene)
	if choices.is_empty():
		push_warning("Bush has no food scenes assigned!")
		return

	var picked: PackedScene = choices[randi() % choices.size()]
	var food_node: Node = picked.instantiate()
	var food: Node2D = food_node as Node2D
	if food == null:
		push_warning("Spawned scene root is not Node2D. Make food root a Node2D/Area2D.")
		return

	# Parent alongside the bush
	var tgt: Node = get_parent()
	if tgt == null:
		tgt = get_tree().current_scene
	tgt.add_child(food)

	# Spawn position: center (or SpawnPoint) + optional offset
	var spawn_pos: Vector2 = _get_spawn_position()
	food.global_position = spawn_pos

	# Draw order bump (stay in front of tiles)
	if food is CanvasItem:
		var ci: CanvasItem = food as CanvasItem
		var self_ci: CanvasItem = self as CanvasItem
		ci.z_index = max(ci.z_index, self_ci.z_index + 1)

	# Find ground directly below
	var ground_y: float = _find_ground_y(spawn_pos, max_fall_distance_px)
	var fall_h: float = max(0.0, ground_y - spawn_pos.y)

	# Animate: fall to ground (no overshoot), two bounces, grow to 2.5x
	_fall_bounce_grow(food, ground_y, fall_h, grow_factor)

	_leaf_shake()

	# One-shot hard lock (also keeps latch closed)
	_spend_bush()

func _start_cooldown() -> void:
	_cooling_down = true
	await get_tree().create_timer(cooldown_seconds).timeout
	_cooling_down = false

func _spend_bush() -> void:
	if _spent:
		return
	_spent = true
	_can_spawn = false
	_player_near = false
	_show_prompt(false)
	monitoring = false
	input_pickable = false
	set_process(false)
	set_physics_process(false)
	if body_entered.is_connected(_on_enter): body_entered.disconnect(_on_enter)
	if body_exited.is_connected(_on_exit): body_exited.disconnect(_on_exit)
	if hide_when_spent:
		visible = false
	elif fade_when_spent:
		var vis2: Node2D = _get_bush_visual()
		if vis2 != null and vis2 is CanvasItem:
			(vis2 as CanvasItem).modulate.a = 0.5
	# keep _input_locked = true forever after spend
	if debug_logs:
		print("[Bush] Spent")

# ---------------- helpers ----------------

func _get_bush_visual() -> Node2D:
	if _sprite2d != null:
		return _sprite2d
	if _anim2d != null:
		return _anim2d
	return null

func _get_spawn_position() -> Vector2:
	if use_spawn_point and has_node("SpawnPoint"):
		return ($SpawnPoint as Node2D).global_position
	return global_position + spawn_offset

func _find_ground_y(from: Vector2, max_dist: float) -> float:
	var to: Vector2 = from + Vector2(0, max_dist)
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var params: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(from, to)
	# Optional: params.collision_mask = 1 << YOUR_GROUND_LAYER
	var hit: Dictionary = space.intersect_ray(params)
	if hit.has("position"):
		return (hit["position"] as Vector2).y
	return to.y

func _fall_bounce_grow(food: Node2D, ground_y: float, fall_h: float, grow_to: float) -> void:
	# Which node to scale (visual child preferred)
	var visual: Node2D = _get_visual_node2d(food)
	var scale_start: Vector2 = visual.scale
	var scale_final: Vector2 = scale_start * grow_to

	# Bounce heights relative to fall height (explicit floats)
	var base: float = fall_h * (0.5 if bounce_base_is_half_fall else 1.0)
	var b1: float = -base * bounce1_frac   # negative = up
	var b2: float = -base * bounce2_frac

	var tw: Tween = create_tween()
	# Fall to ground (no overshoot) + grow in parallel
	tw.parallel().tween_property(food, "global_position:y", ground_y, fall_time_s)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(visual, "scale", scale_final, fall_time_s)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Bounce 1
	tw.tween_property(food, "global_position:y", ground_y + b1, 0.12)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(food, "global_position:y", ground_y, 0.12)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Bounce 2
	tw.tween_property(food, "global_position:y", ground_y + b2, 0.09)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(food, "global_position:y", ground_y, 0.09)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _get_visual_node2d(food: Node2D) -> Node2D:
	if !scale_visual_child:
		return food
	var child_sprite: Sprite2D = food.get_node_or_null("Sprite2D") as Sprite2D
	if child_sprite != null:
		return child_sprite
	var child_anim: AnimatedSprite2D = food.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if child_anim != null:
		return child_anim
	return food

func _leaf_shake() -> void:
	var vis: Node2D = _get_bush_visual()
	if vis == null:
		return
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	vis.scale = _base_scale
	_shake_tween = create_tween()
	_shake_tween.tween_property(vis, "scale", _base_scale * 1.06, 0.08)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_shake_tween.tween_property(vis, "scale", _base_scale, 0.10)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
