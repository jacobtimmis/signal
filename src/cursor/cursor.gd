extends Control


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        global_position = event.position


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
