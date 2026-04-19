class_name Combat
extends Node


static func damage(body: Node, amount: float, context: CombatContext) -> bool:
    if body is Hero:
        return body.health_component.damage(amount, context)
    elif body is Enemy:
        return body.health_component.damage(amount, context)
    else:
        push_warning("Trying to damage node that doesn't have a health component: %s" % body.get_path())
        return false
