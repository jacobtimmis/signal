class_name UI
extends Control

@export var hero: Hero
@onready var health_bar: ProgressBar = %HealthBar
@export var score_manager: ScoreManager
@onready var score_label: Label = %ScoreLabel
@onready var xp_bar: ProgressBar = %XpBar
@onready var time: Label = %Time
@onready var top_container: HBoxContainer = %TopContainer


func _ready() -> void:
    time.hide()


func _process(delta: float) -> void:
    if hero:
        health_bar.value = hero.health_component.percent()
        if hero.health_component.is_dead():
            time.show()
            time.text = "survived %.1fs" % hero.survive_time
    if score_manager:
        score_label.text = str(score_manager.inst.score)
        xp_bar.value = float(score_manager.xp) / float(score_manager.max_xp)
