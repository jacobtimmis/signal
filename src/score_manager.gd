class_name ScoreManager
extends Node

static var inst: ScoreManager
var score: int

func _ready() -> void:
    inst = self


static func add_score(amount: int) -> void:
    inst.score += amount
