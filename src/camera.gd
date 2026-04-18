class_name GameCamera
extends Camera2D

static var instance: GameCamera

var _shake_intensity: float = 0.0
var _shake_damping: float = 5.0


static func shake(intensity: float, damping: float = 5.0) -> void:
    if instance:
        instance._shake_intensity = intensity
        instance._shake_damping = damping


func _ready() -> void:
    instance = self


func _process(delta: float) -> void:
    if _shake_intensity > 0:
        _shake_intensity = lerp(_shake_intensity, 0.0, _shake_damping * delta)
        offset = Vector2(
            randf_range(-_shake_intensity, _shake_intensity),
            randf_range(-_shake_intensity, _shake_intensity),
        )
    else:
        offset = Vector2.ZERO
