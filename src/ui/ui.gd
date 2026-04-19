class_name UI
extends Control

@export var hero: Hero
@onready var health_bar: ProgressBar = %HealthBar
@export var score_manager: ScoreManager
@onready var score_label: Label = %ScoreLabel


func _process(delta: float) -> void:
    if hero:
        health_bar.value = hero.health_component.percent()
    if score_manager:
        score_label.text = str(score_manager.inst.score)
