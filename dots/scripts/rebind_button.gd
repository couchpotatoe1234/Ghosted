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
	text = "Press a key..."

func _unhandled_input(event: InputEvent) -> void:
	if not is_listening:
		return
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, event)
		is_listening = false
		update_button_text()
		get_viewport().set_input_as_handled()
