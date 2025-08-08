extends UI

@onready var panel = $Panel
var ftb: bool = false
var fofb: bool = false
var current_alpha: float = 1.0

func _physics_process(delta):
	if ftb:
		panel.modulate.a = move_toward(panel.modulate.a, 1, delta)
		if panel.modulate.a == 1:
			ftb = false
	elif fofb:
		panel.modulate.a = move_toward(panel.modulate.a, 0, delta)
		if panel.modulate.a == 0:
			fofb = false
	else:
		pass

func fade_to_black() -> void:
	ftb = true

func fade_out_from_black() -> void:
	fofb = true
