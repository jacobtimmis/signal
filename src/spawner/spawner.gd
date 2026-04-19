extends Node2D
class_name Spawner
const BACKUP_ENCOUNTER = preload("uid://dmdk00ynqxu5n")

@export var layer: Node2D
var current_heat: int = 0
var encounters: Array[EncounterData]
@export var scenes: Array[PackedScene]
@export var spawn_radius: float = 300.0
@export var spawn_interval: float = 1.0
@export var total_positions: int = 12
@export var chance_to_flip := 0.1

var current_spawn_index: int = 0

func _ready() -> void:
    for file in DirAccess.get_files_at("res://data/encounters/"):
        encounters.append(ResourceLoader.load("res://data/encounters/" + file))

    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = spawn_interval
    timer.timeout.connect(_spawn_enemy)
    timer.start()


func _pick_encounter() -> EncounterData:
    if encounters.size() == 0:
        return BACKUP_ENCOUNTER
    return encounters.pick_random()


func _spawn_enemy() -> void:
    if encounters.is_empty() or not layer:
        return

    var encounter = _pick_encounter()
    var angle = (TAU / total_positions) * current_spawn_index - (PI / 2.0)
    var spawn_point = global_position + Vector2.RIGHT.rotated(angle) * spawn_radius

    for spawn in encounter.spawns:
        for n in randi_range(spawn.min_amount, spawn.max_amount):
            var instance = spawn.scene.instantiate()
            layer.add_child(instance)
            
            var spread = Vector2(randf_range(-32, 32), randf_range(-32, 32))
            instance.global_position = spawn_point + spread

    if randf() <= chance_to_flip:
        current_spawn_index = (current_spawn_index + (total_positions / 2)) % total_positions
    else:
        current_spawn_index = (current_spawn_index + 1) % total_positions
