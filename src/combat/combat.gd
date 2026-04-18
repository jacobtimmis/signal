class_name Combat
extends Node


static func damage(body: Node, amount: float, context: CombatContext) -> void:
    if body is Hero:
        body.health_component.damage(amount, context)
    elif body is Enemy:
        body.health_component.damage(amount, context)
    else:
        push_warning("Trying to damage node that doesn't have a health component: %s" % body.get_path())
