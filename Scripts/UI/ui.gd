class_name UI
extends Control

@onready var start_menu: Control = $StartMenu
@onready var pause_menu: Control = $PauseMenu
@onready var pause_menu_bg = $PauseMenu/Panel
@onready var pause_menu_ui = $PauseMenu/MarginContainer
@onready var hud: Control = $HUD
@onready var death_screen: Control = $DeathScreen
@onready var win_screen: Control = $WinScreen
@onready var scene_transition: Control = $SceneTransition
@onready var panel: Panel = $SceneTransition/Panel
@onready var progress_bar = $HUD/MarginContainer/ProgressBar
@onready var main: Node2D = get_tree().get_first_node_in_group("Main")

var ftb: bool = false
var fofb: bool = false
var pmfi: bool = false
var pmfo: bool = false
var pm_in_pos: bool = false
var gwfi: bool = false
var gwfo: bool = false
var gofi: bool = false
var gofo: bool = false
var transition_active: bool = false

func _ready():
	for child in get_children():
		if child.name == "StartMenu" or child.name == "SceneTransition":
			child.visible = true
		else:
			child.visible = false

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
	
	#region: Pause menu partial fade in/out
	if pmfi:
		if !transition_active:
			transition_active = true
		if !pause_menu.visible:
			pause_menu.visible = true
			pause_menu_bg.visible = true
		pause_menu_bg.modulate.a = move_toward(pause_menu_bg.modulate.a, 0.25, delta * 0.5)
		if pause_menu_ui.position.y != 580:
			pause_menu_ui.position.y = move_toward(pause_menu_ui.position.y, 580, delta * 1000)
		if pause_menu_bg.modulate.a == 0.25:
			pmfi = false
			transition_active = false
	elif pmfo:
		if !transition_active:
			transition_active = true
		pause_menu_bg.modulate.a = move_toward(pause_menu_bg.modulate.a, 0, delta * 0.5)
		if pause_menu_ui.position.y != 1100:
			pause_menu_ui.position.y = move_toward(pause_menu_ui.position.y, 1100, delta * 1000)
		if pause_menu_bg.modulate.a == 0:
			pmfo = false
			transition_active = false
		if pause_menu_ui.position.y == 1100:
			pause_menu.visible = false
			pause_menu_bg.visible = false
	else:
		pass
	#endregion
	
	if gofi:
		if !death_screen.visible:
			death_screen.visible = true
		death_screen.modulate.a = move_toward(death_screen.modulate.a, 1, delta)
		if death_screen.modulate.a == 1:
			gofi = false
			get_tree().paused = true
	#elif gofo:
		#death_screen.modulate.a = move_toward(death_screen.modulate.a, 0, delta)
		#if death_screen.modulate.a == 0:
			#gofo = false
			#get_tree().paused = false
	
	if gwfi:
		if !win_screen.visible:
			win_screen.visible = true
		win_screen.modulate.a = move_toward(win_screen.modulate.a, 1, delta)
		if win_screen.modulate.a == 1:
			gwfi = false
			get_tree().paused = true
	#elif gwfo:
		#win_screen.modulate.a = move_toward(win_screen.modulate.a, 0, delta)
		#if win_screen.modulate.a == 0:
			#gwfo = false
			#get_tree().paused = false

func fade_to_black():
	ftb = true

func fade_out_from_black():
	fofb = true

func pause_menu_fade_in():
	pmfo = false
	pmfi = true

func pause_menu_fade_out():
	pmfi = false
	pmfo = true

func show_game_over_screen():
	gofi = true
	fade_to_black()

#func hide_game_over_screen():
	#gofo = true

func show_victory_screen():
	gwfi = true
	fade_to_black()

#func hide_victory_screen():
	#gwfo = true

func _on_start_button_button_up():
	main.change_level(2)

func _on_quit_button_button_up():
	get_tree().quit()

func update_health():
	progress_bar.value = main.player.current_health

func show_hud_only():
	for child in get_children():
		if child == scene_transition:
			pass
		elif child != hud:
			child.visible = false
		else:
			child.visible = true

func pause_button_pressed():
	if get_tree().paused:
		pause_menu_fade_out()
		get_tree().paused = false
	else:
		pause_menu_fade_in()
		get_tree().paused = true

func return_to_menu_button_pressed():
	hud.visible = false
	start_menu.visible = true
	if death_screen.visible:
		death_screen.visible = false
		await main.change_level(0)
		fade_out_from_black()
	if win_screen.visible:
		win_screen.visible = false
		await main.change_level(0)
		fade_out_from_black()
	for child in get_children():
		if child == start_menu or child == scene_transition:
			child.visible = true
		elif child.visible == true:
			child.visible = false
