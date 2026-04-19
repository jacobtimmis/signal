extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
    if body is Hero and body.health_component.is_damaged():
        body.health_component.current_health += 50
        body.play_heal_sound()
        queue_free()
