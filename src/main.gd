class_name Main
extends Node

@onready var subviewport_node: SubViewport = %Viewport
@onready var viewport_texture: ColorRect = %ViewportTexture


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("restart_level"):
        get_tree().reload_current_scene.call_deferred()

    if event is InputEventMouse:
        event.position -= viewport_texture.position
        event.position *= Vector2(Vector2(subviewport_node.size) / viewport_texture.size)

    subviewport_node.push_input(event)
