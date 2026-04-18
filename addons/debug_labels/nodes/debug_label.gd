@tool
@abstract
class_name DebugLabel
extends Label

@export var root_node: Node:
    set(value):
        root_node = value
        _update_text()
@export var prefix: String:
    set(value):
        prefix = value
        _update_text()
@export var suffix: String:
    set(value):
        suffix = value
        _update_text()


func _enter_tree() -> void:
    if not root_node:
        root_node = get_parent()
    _update_text()


func _process(_delta: float) -> void:
    if not Engine.is_editor_hint() and get_root_node():
        _update_text()


func get_root_node() -> Node:
    return root_node


func str_format(value: Variant) -> String:
    if value is Node:
        return value.name
    if value is float:
        return "%.02f" % value
    if value is Vector2:
        return "(%.02f, %.02f)" % [value.x, value.y]
    if value is Vector3:
        return "(%.02f, %.02f, %.02f)" % [value.x, value.y, value.z]
    return str(value)


@abstract
func _get_value() -> Variant


func _update_text() -> void:
    var text_to_use: String
    if Engine.is_editor_hint() and not _get_value():
        text_to_use = "[value]"
    else:
        text_to_use = str_format(_get_value())
        text_to_use = text_to_use.strip_edges()
    var prefix_to_use := prefix.strip_edges()
    var suffix_to_use := suffix.strip_edges()
    text = prefix_to_use + DebugLabelsHelper.get_separator() + text_to_use + suffix_to_use
