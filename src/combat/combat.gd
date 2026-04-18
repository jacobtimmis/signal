class_name Combat
extends Node


static func damage(body: Node, amount: float) -> void:
    if body is Hero:
        body.health_component.damage(amount)
    elif body is Enemy:
        body.health_component.damage(amount)
    else:
        push_warning("Trying to damage node that doesn't have a health component: %s" % body.get_path())
