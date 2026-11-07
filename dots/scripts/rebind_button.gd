extends TextureButton

@export var action_name: String = ""

@onready var label: Label = $Label

static var listening_button: TextureButton = null


func _ready() -> void:
	update_button_text()
	pressed.connect(_on_button_pressed)
	
func update_button_text() -> void:
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		var event = events[0]
		if event is InputEventKey:
			label.text = OS.get_keycode_string(event.physical_keycode) if event.physical_keycode != 0 else event.as_text()
		else:
			label.text = event.as_text()
	else:
		label.text = "Unbound"

func _on_button_pressed() -> void:
	if listening_button != null and listening_button != self:
		return
	listening_button = self
	label.text = "Press a key..."

func _unhandled_input(event: InputEvent) -> void:
	if listening_button != self:
		return
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			listening_button = null
			update_button_text()
			get_viewport().set_input_as_handled()
			return
		for act in InputMap.get_actions():
			if act.begins_with("ui_"): continue
			for existing_event in InputMap.action_get_events(act):
				if existing_event is InputEventKey:
					if existing_event.keycode == event.keycode or (event.physical_keycode != 0 and existing_event.physical_keycode == event.physical_keycode):
						InputMap.action_erase_event(act, existing_event)
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, event)
		listening_button = null
		update_button_text()
		get_tree().call_group("rebind_buttons", "update_button_text")
		get_viewport().set_input_as_handled()
