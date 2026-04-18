extends Node

@export var subviewport_node: SubViewport

@onready var viewport_texture: ColorRect = $ViewportTexture


func _input(event: InputEvent) -> void:
    if event is InputEventMouse:
        event.position -= viewport_texture.position
        event.position *= Vector2(Vector2(subviewport_node.size) / viewport_texture.size)
        event.position -= Vector2(subviewport_node.size) / 2

    subviewport_node.push_input(event)
