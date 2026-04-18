@tool
class_name PropertyLabel
extends DebugLabel

@export var property: StringName:
    set(value):
        property = value
        _update_text()


func _get_value() -> Variant:
    if get_root_node():
        return get_root_node().get(property)
    return null
