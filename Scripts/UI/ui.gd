class_name UI
extends Control

@onready var start_menu: Control = $StartMenu
@onready var pause_menu: Control = $PauseMenu
@onready var user_interface: Control = $UserInterface
@onready var death_screen: Control = $DeathScreen
@onready var win_screen: Control = $WinScreen
@onready var scene_transition: Control = $SceneTransition
var main: Node2D
var panel: Panel
var ftb: bool = false
var fofb: bool = false
var transition_active: bool = false
var current_alpha: float = 1.0


func _ready():
	main = get_tree().get_first_node_in_group("Main")
	if scene_transition.get_child(0).get_class() == "Panel":
		panel = scene_transition.get_child(0)

func _physics_process(delta):
	#region: Scene transition fade in/out
	if ftb:
		if !transition_active:
			transition_active = true
		if !scene_transition.visible:
			scene_transition.visible = true
		panel.modulate.a = move_toward(panel.modulate.a, 1, delta)
		if panel.modulate.a == 1:
			ftb = false
			transition_active = false
	elif fofb:
		if !transition_active:
			transition_active = true
		panel.modulate.a = move_toward(panel.modulate.a, 0, delta)
		if panel.modulate.a == 0:
			fofb = false
			scene_transition.visible = false
			transition_active = false
	else:
		pass
	#endregion

func fade_to_black():
	ftb = true
	await get_tree().create_timer(1).timeout

func fade_out_from_black():
	fofb = true
	await get_tree().create_timer(1).timeout

func _on_start_button_button_up():
	main.change_level(1)
	#await fade_out_from_black()

func _on_quit_button_button_up():
	get_tree().quit()
