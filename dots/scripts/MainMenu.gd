extends CanvasLayer

@onready var click_sound: AudioStreamPlayer = $Click
signal play_pressed

func _on_start_pressed() -> void:
	click_sound.play()
	play_pressed.emit()
	

func _on_quit_pressed() -> void:
	click_sound.play()
	get_tree().quit()
