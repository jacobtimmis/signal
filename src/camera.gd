class_name GameCamera
extends Camera2D

signal is_fullmap_updated(new_value: bool)

static var instance: GameCamera

@export var follow_node: Node2D
@export var view_size: Vector2
@export var min_position: Vector2
@export var max_position := Vector2.ONE
@export var interp_speed: float = 5

var is_fullmap := false
var _shake_intensity: float = 0.0
var _shake_damping: float = 5.0


static func shake(intensity: float, damping: float = 5.0) -> void:
    if instance:
        instance._shake_intensity = intensity
        instance._shake_damping = damping


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_debug_fullmap"):
        is_fullmap = not is_fullmap
        is_fullmap_updated.emit(is_fullmap)
        zoom = Vector2(.5, .5) if is_fullmap else Vector2.ONE
        if not is_fullmap:
            global_position = _get_desired_position()


func _ready() -> void:
    instance = self

    var half := view_size / 2
    min_position += half
    max_position -= half



func _get_desired_position() -> Vector2:
    var desired_position: Vector2
    desired_position.x = clampf(follow_node.global_position.x, min_position.x, max_position.x)
    desired_position.y = clampf(follow_node.global_position.y, min_position.y, max_position.y)
    return desired_position

func _process(delta: float) -> void:
    if _shake_intensity > 0:
        _shake_intensity = lerp(_shake_intensity, 0.0, _shake_damping * delta)
        offset = Vector2(
            randf_range(-_shake_intensity, _shake_intensity),
            randf_range(-_shake_intensity, _shake_intensity),
        )
    else:
        offset = Vector2.ZERO

    if follow_node and not is_fullmap:
        global_position = global_position.move_toward(_get_desired_position(), interp_speed * delta)
    else:
        global_position = Vector2(144, 144)
