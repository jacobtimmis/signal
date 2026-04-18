extends CanvasLayer


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_debug_info") and OS.is_debug_build():
        visible = not visible
