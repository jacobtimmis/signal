class_name MuzzleFlash
extends PointLight2D

@export var tween_duration: float = 0.1


func _enter_tree() -> void:
    color.a = 0


func play() -> void:
    color.a = 1
    var tween := create_tween()
    tween.tween_property(self, "color:a", 0, tween_duration)
