@tool
class_name ExpressionLabel
extends DebugLabel

@export_custom(PROPERTY_HINT_EXPRESSION, "") var expression: String

var valid_expression := false
var _expression := Expression.new()


func _ready() -> void:
    if Engine.is_editor_hint():
        return

    var parse_result = _expression.parse(expression)
    if parse_result != OK:
        push_error("ExpressionLabel %s failed parsing expression: %s" \
            % [self.name, _expression.get_error_text()])
        valid_expression = false
    else:
        valid_expression = true


func _get_value() -> Variant:
    if not Engine.is_editor_hint() and valid_expression:
        return _expression.execute([], get_root_node(), false)
    return null
