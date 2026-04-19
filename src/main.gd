class_name Main
extends Node

@export var subviewport_node: SubViewport

@onready var viewport_texture: ColorRect = $ViewportTexture
static var inst: Main
@onready var game: Node2D = %Game

func _ready() -> void:
    inst = self


func hitstop(dur: float) -> void:
    game.process_mode = Node.PROCESS_MODE_DISABLED
    await get_tree().create_timer(dur).timeout
    game.process_mode = Node.PROCESS_MODE_INHERIT


func _input(event: InputEvent) -> void:
    if event is InputEventMouse:
        event.position -= viewport_texture.position
        event.position *= Vector2(Vector2(subviewport_node.size) / viewport_texture.size)
        event.position -= Vector2(subviewport_node.size) / 2

    if is_inside_tree() and subviewport_node.is_inside_tree():
        # there is an error here when scene is reloaded
        # not critical
        subviewport_node.push_input(event)
