class_name UI
extends Control

@export var hero: Hero
@onready var health_bar: ProgressBar = %HealthBar


func _process(delta: float) -> void:
    if hero:
        health_bar.value = hero.health_component.percent()
