class_name DebugInfoLayer
extends CanvasLayer


func _ready() -> void:
    hide()


func _input(event: InputEvent) -> void:
    if OS.is_debug_build() and event.is_action_pressed("toggle_debug_info"):
        visible = not visible
