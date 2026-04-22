extends Control

@onready var health_bar: ProgressBar = %HealthBar


func _process(delta: float) -> void:
    health_bar.value = Game.get_hero().health_component.percent()
