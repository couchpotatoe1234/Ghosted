extends CanvasLayer

@onready var click_sound: AudioStreamPlayer = $Click
@onready var main: Node2D = $"/root/Main"
signal play_pressed

func _ready() -> void:
	print(GameManager.controls_allowed)

func _on_start_pressed() -> void:
	if GameManager.controls_allowed:
		click_sound.play()
		play_pressed.emit()
		GameManager.controls_allowed = false
	

func _on_quit_pressed() -> void:
	click_sound.play()
	get_tree().quit()

func _on_settings_pressed() -> void:
	if GameManager.controls_allowed:
		click_sound.play()
		main.load_settings()
		GameManager.controls_allowed = false
