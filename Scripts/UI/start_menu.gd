extends UI

func _on_start_button_button_up():
	main.change_level(1)

func _on_quit_button_button_up():
	get_tree().quit()
