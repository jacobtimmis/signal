class_name EndScreen
extends Control

@onready var score_label: Label = %ScoreLabel
@onready var time_label: Label = %TimeLabel


func _ready() -> void:
    hide()


func update_and_show(score: int, time: float) -> void:
    score_label.text = "scored %s" % score
    time_label.text = "survived %.1fs" % time
    show()
