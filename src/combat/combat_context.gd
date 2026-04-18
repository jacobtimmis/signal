class_name CombatContext
extends RefCounted

var from: Node2D
var attack_direction: Vector2

func _init(i_from: Node2D, i_dir := Vector2.ZERO) -> void:
    from = i_from
    attack_direction = i_dir
