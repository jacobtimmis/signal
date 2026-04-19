extends Node2D
class_name Spawner

@export var layer: Node2D
var current_heat: int = 0: set = _set_current_heat
var encounters: Array[EncounterData]
@export var scenes: Array[PackedScene]
@export var spawn_radius: float = 300.0
@export var spawn_interval: float = 1.0
@export var total_positions: int = 12
@export var chance_to_flip := 0.1
static var inst: Spawner

var current_spawn_index: int = 0


func _set_current_heat(value: int) -> void:
    current_heat = clampi(value, 0, 100)


func _ready() -> void:
    inst = self

    for file in DirAccess.get_files_at("res://data/encounters/"):
        encounters.append(ResourceLoader.load("res://data/encounters/" + file))

    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = spawn_interval
    timer.timeout.connect(_spawn_enemy)
    timer.start()


func _pick_encounter() -> EncounterData:
    var valid_encounters: Array[EncounterData]
    for e in encounters:
        if current_heat >= e.min_heat and current_heat <= e.max_heat:
            valid_encounters.append(e)
    if valid_encounters.size() == 0:
        return load("uid://dmdk00ynqxu5n")
    return valid_encounters.pick_random()


func _spawn_enemy() -> void:
    if Hero.inst.health_component.is_dead():
        return

    if encounters.is_empty() or not layer:
        return

    var encounter = _pick_encounter()
    print("New Encounter: %s" % encounter.resource_path.get_file())
    _do_spawn(encounter)


func _do_spawn(encounter: EncounterData):
    var angle = (TAU / total_positions) * current_spawn_index - (PI / 2.0)
    var spawn_point = global_position + Vector2.RIGHT.rotated(angle) * spawn_radius

    for spawn in encounter.spawns:
        for n in randi_range(spawn.min_amount, spawn.max_amount):
            var instance = spawn.scene.instantiate()

            var spread = Vector2(randf_range(-32, 32), randf_range(-32, 32))
            instance.global_position = spawn_point + spread

            layer.add_child.call_deferred(instance)

        if spawn.spawn_poof:
            var poof := spawn.spawn_poof.instantiate() as Node2D
            poof.global_position = spawn_point
            add_child(poof)

    if randf() <= chance_to_flip:
        current_spawn_index = (current_spawn_index + (total_positions / 2)) % total_positions
    else:
        current_spawn_index = (current_spawn_index + 1) % total_positions
