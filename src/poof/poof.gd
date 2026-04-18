@tool
class_name Poof
extends Node2D

@export_tool_button("Play") var play_button := start

var active_nodes: int


func _ready() -> void:
    start()


func start():
    for c in get_children():
        if c is AudioStreamPlayer2D:
            c.play()
            if not Engine.is_editor_hint():
                c.finished.connect(_node_finished)
                active_nodes += 1
        if c is CPUParticles2D:
            c.restart()
            if not Engine.is_editor_hint():
                c.finished.connect(_node_finished)
                active_nodes += 1


func _node_finished() -> void:
    active_nodes -= 1
    if active_nodes <= 0:
        queue_free()
