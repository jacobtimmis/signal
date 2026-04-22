class_name ToggleableTexture
extends TextureRect


@export var fullmap_texture: Texture2D
var _original_texture: Texture2D


func _on_game_camera_is_fullmap_updated(new_value: bool) -> void:
    if not _original_texture:
        _original_texture = texture
    if new_value:
        texture = fullmap_texture
    else:
        texture = _original_texture
