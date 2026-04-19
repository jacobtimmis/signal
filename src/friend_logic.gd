extends Node


func _on_hurtbox_dealt_damage() -> void:
    Hero.inst.add_random_upgrade()
