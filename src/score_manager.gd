class_name ScoreManager
extends Node

signal levelled_up
static var inst: ScoreManager
var score: int
var xp: int: set = _set_xp
var max_xp: int = 3

func _ready() -> void:
    inst = self


func _set_xp(value) -> void:
    xp = value
    if xp >= max_xp:
        max_xp += 1
        xp = 0
        levelled_up.emit()


static func add_score(amount: int) -> void:
    inst.score += amount
