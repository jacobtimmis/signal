extends Control


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        global_position = event.position
