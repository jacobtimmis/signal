extends ColorRect

func _ready() -> void:
    show()
    var tween := create_tween()
    tween.tween_property(self, "modulate:a", 0, 1)
