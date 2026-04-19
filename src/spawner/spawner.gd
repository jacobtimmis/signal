extends Node2D
class_name Spawner

@export var layer: Node2D
@export var scenes: Array[PackedScene]
@export var spawn_radius: float = 300.0
@export var spawn_interval: float = 1.0
@export var total_positions: int = 12
@export var chance_to_flip := 0.1

var current_spawn_index: int = 0

func _ready() -> void:
    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = spawn_interval
    timer.timeout.connect(_spawn_enemy)
    timer.start()

func _spawn_enemy() -> void:
    if scenes.is_empty() or not layer:
        return

    var angle = (TAU / total_positions) * current_spawn_index - (PI / 2.0)
    var spawn_offset = Vector2.RIGHT.rotated(angle) * spawn_radius

    var instance = scenes.pick_random().instantiate()
    layer.add_child(instance)
    instance.global_position = global_position + spawn_offset

    if randf() <= chance_to_flip:
        current_spawn_index = (current_spawn_index + (total_positions / 2)) % total_positions
    else:
        current_spawn_index = (current_spawn_index + 1) % total_positions
