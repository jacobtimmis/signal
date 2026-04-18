@tool
class_name DebugLabelsPlugin
extends EditorPlugin


func _enter_tree():
    print("Debug Labels Plugin Enabled")
    DebugLabelsHelper.setup_from_editor()


func _exit_tree():
    print("Debug Labels Plugin Disabled")
