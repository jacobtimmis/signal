class_name Hurtbox extends Area2D

signal dealt_damage

@export var from: Node2D
@export var damage: float = 10


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    var context := CombatContext.new()
    context.from = from
    Combat.damage(body, damage, context)
    dealt_damage.emit()
