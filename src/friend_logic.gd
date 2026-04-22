extends Node


func _on_hurtbox_dealt_damage() -> void:
    Game.get_hero().add_random_upgrade()
