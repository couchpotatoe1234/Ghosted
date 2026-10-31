extends Button

@export var action_name: String = ""
var is_listening: bool = false

func _ready() -> void:
	update_button_text()
	pressed.connect(_on_button_pressed)
	
func update_button_text() -> void:
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		text = events[0].as_text().trim_suffix(" (Physical)")
	else:
		text = "Unbound"

func _on_button_pressed() -> void:
	is_listening = true
	text = "Press key to rebind to..."
