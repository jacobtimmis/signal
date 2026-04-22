class_name Main
extends Node

@onready var subviewport_node: SubViewport = %Viewport
@onready var viewport_texture: ColorRect = %ViewportTexture


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("restart_level") and OS.is_debug_build():
        get_tree().reload_current_scene.call_deferred()
        return

    if event.is_action_pressed("toggle_crt") and OS.is_debug_build():
        var viewport_material := viewport_texture.material as ShaderMaterial
        var is_enabled := viewport_material.get_shader_parameter("enabled") as bool
        viewport_material.set_shader_parameter("enabled", not is_enabled)
        return

    if event is InputEventMouse:
        event.position -= viewport_texture.position
        event.position *= Vector2(Vector2(subviewport_node.size) / viewport_texture.size)

    subviewport_node.push_input(event)
