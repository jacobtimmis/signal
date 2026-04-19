extends Node2D

var text: String

@onready var label: Label = $Label


func _ready() -> void:
    if label:
        label.text = text


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    queue_free()
