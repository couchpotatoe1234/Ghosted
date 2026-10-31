extends CanvasLayer

signal return_to_main_menu

func _on_main_menu_pressed() -> void:
	return_to_main_menu.emit()
