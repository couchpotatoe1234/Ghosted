extends PointLight2D


func _ready() -> void:
	if GameManager.block1_broken:
		position = Vector2(2074, -411)
	else:
		position = Vector2(2047.9065, -413.973)


func _process(_delta: float) -> void:
	if GameManager.block1_broken:
		position = Vector2(2074, -411)
