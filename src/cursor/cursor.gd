extends Control


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    GlobalInput.input_device_changed.connect(_on_input_device_changed)
    _on_input_device_changed(GlobalInput.current_device)


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        global_position = event.position


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_input_device_changed(_old_device: GlobalInput.Device) -> void:
    if GlobalInput.current_device == GlobalInput.Device.MOUSE:
        show()
    else:
        hide()
