extends CharacterBody2D

const SPEED = 70.0
const ACCEL = 1000.0
const DECEL = 1000.0

var wish_dir: Vector2


func _physics_process(delta: float) -> void:
    wish_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if wish_dir:
        _accelerate(delta)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, get_decel() * delta)

    move_and_slide()


func get_speed() -> float:
    return SPEED


func get_accel() -> float:
    return ACCEL


func get_decel() -> float:
    return DECEL


func _accelerate(delta: float) -> void:
    velocity += wish_dir * get_accel() * delta
    if velocity.length() > get_speed():
        velocity = velocity.limit_length(get_speed())
