extends Node2D
class_name Spawner

var current_heat: int = 0: set = _set_current_heat
var encounters: Array[EncounterData]
@export var scenes: Array[PackedScene]
@export var spawn_radius: float = 300.0
@export var spawn_interval: float = 1.0
@export var total_positions: int = 12
@export var chance_to_flip := 0.1
static var inst: Spawner
var timer: Timer

var current_spawn_index: int = 0


func _set_current_heat(value: int) -> void:
    current_heat = clampi(value, 0, 100)


func _ready() -> void:
    inst = self

    for file in DirAccess.get_files_at("res://data/encounters/"):
        encounters.append(ResourceLoader.load("res://data/encounters/" + file))

    timer = Timer.new()
    add_child(timer)
    timer.wait_time = spawn_interval
    timer.timeout.connect(_spawn_enemy)
    timer.start()
    #await get_tree().create_timer(1).timeout
    #_spawn_enemy()


var one_use_used: Array[String]
func _pick_encounter() -> EncounterData:
    var valid_encounters: Array[EncounterData]
    for e in encounters:
        if current_heat >= e.min_heat and current_heat <= e.max_heat and e.resource_path not in one_use_used:
            valid_encounters.append(e)
    if valid_encounters.size() == 0:
        return load("uid://dmdk00ynqxu5n")
    var random := valid_encounters.pick_random() as EncounterData
    if random.one_use:
        one_use_used.append(random.resource_path)
    return random


func _spawn_enemy() -> void:
    if Game.get_hero().health_component.is_dead():
        return

    if encounters.is_empty():
        return

    timer.wait_time = max(timer.wait_time - 0.5, 2)

    var encounter = _pick_encounter()
    print("New Encounter: %s" % encounter.resource_path.get_file())
    _do_spawn(encounter)


func _do_spawn(encounter: EncounterData):
    var angle = (TAU / total_positions) * current_spawn_index - deg_to_rad(90)
    var spawn_point := global_position + Vector2.RIGHT.rotated(angle) * spawn_radius

    for spawn in encounter.spawns:
        if not spawn:
            continue
        for n in randi_range(spawn.min_amount, spawn.max_amount):
            var instance = spawn.scene.instantiate()

            #var spread := Vector2(randf_range(-32, 32), randf_range(-32, 32))
            #var new_pos := spawn_point + spread
            instance.global_position = spawn_point

            print("Enemy spawned at %s" % instance.global_position)

            Game.get_entity_layer().add_child.call_deferred(instance)

        if spawn.spawn_poof:
            var poof := spawn.spawn_poof.instantiate() as Node2D
            poof.global_position = spawn_point
            add_child(poof)

    current_spawn_index = (current_spawn_index + 1) % total_positions
