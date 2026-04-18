extends Line2D


var target_position: Vector2


func _process(delta: float) -> void:
    look_at(target_position)
