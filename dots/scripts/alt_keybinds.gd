extends Button


func _on_pressed() -> void:
	var keybinds = {
		"up": KEY_UP,
		"down": KEY_DOWN,
		"left": KEY_LEFT,
		"right": KEY_RIGHT,
		"Jump": KEY_Z,
		"Attack": KEY_X,
		"heal": KEY_A,
		"dash": KEY_C
	}
	for action in keybinds:
		InputMap.action_erase_events(action)
		var event = InputEventKey.new()
		event.physical_keycode = keybinds[action]
		InputMap.action_add_event(action, event)
		#button1.update_button_text()
		#button2.update_button_text()
		#button3.update_button_text()
		#button4.update_button_text()
		#button5.update_button_text()
		#button6.update_button_text()
		#button7.update_button_text()
		#button8.update_button_text()
