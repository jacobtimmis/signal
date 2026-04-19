class_name Hero
extends CharacterBody2D

enum State { DEFAULT, DASH, DEAD }

const MOVE_CALLABLE = &"move"
const SPEED = 70.0
const ACCEL = 1000.0
const DECEL = 400.0
const DASH_ACCEL = 1000.0
const DASH_SPEED = 140.0
const DASH_DECEL = 300.0
const CONTROL_AIM_DEADZONE = 0.5

static var inst: Hero

var state_machine := StateMachine.new()
var wish_dir: Vector2
var last_non_zero_wish_dir: Vector2
var dash_dir: Vector2
var dash_time: float
var mouse_position: Vector2
var _control_aim_dir := Vector2.RIGHT
var survive_time: float
var can_continue_death := false

@onready var weapon_alt: Weapon = $WeaponAlt
@onready var health_component: HealthComponent = $HealthComponent
@onready var shoot_light: PointLight2D = $ShootLight
@onready var weapon: Weapon = $Weapon

@export var spawner: Spawner


func _ready() -> void:
    inst = self

    shoot_light.color.a = 0

    state_machine.setup_state(
        State.DEFAULT,
        {
            MOVE_CALLABLE: _normal_move,
        },
    )
    state_machine.setup_state(
        State.DASH,
        {
            StateMachine.ENTER_CALLABLE: _dash_enter,
            StateMachine.EXIT_CALLABLE: _dash_exit,
            MOVE_CALLABLE: _dash_move,
        },
    )
    state_machine.setup_state(
        State.DEAD,
        {
            StateMachine.CAN_EXIT_CALLABLE: _dead_can_exit,
            StateMachine.ENTER_CALLABLE: _dead_enter,
        },
    )
    state_machine.setup_names_from_enum(State)

    weapon.data = weapon.data.duplicate()
    weapon_alt.data = weapon_alt.data.duplicate()

    $DashParticles.emitting = false

    await get_tree().create_timer(0.5).timeout
    friend_signal()
    for n in range(3):
        friend_signal()
        await get_tree().create_timer(0.5).timeout

func _process(_delta: float) -> void:
    if health_component.is_dead():
        return

    survive_time += _delta

    var current_aim_dir := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
    if current_aim_dir.length() > CONTROL_AIM_DEADZONE:
        _control_aim_dir = current_aim_dir
        _control_aim_dir = _control_aim_dir.normalized()

    $AimLine.target_position = get_aim_target_position()
    $Weapon.target_position = get_aim_target_position()
    $WeaponAlt.target_position = get_aim_target_position()
    if Input.is_action_pressed("shoot") or current_aim_dir.length() > CONTROL_AIM_DEADZONE:
        $Weapon._shoot()
    if Input.is_action_pressed("shoot_alt"):
        $WeaponAlt._shoot()


func _physics_process(delta: float) -> void:
    if health_component.is_dead():
        return

    wish_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    wish_dir = wish_dir.normalized()

    if wish_dir.length() != 0:
        last_non_zero_wish_dir = wish_dir

    state_machine.current_state_call_callable(MOVE_CALLABLE, [delta])

    move_and_slide()


func _input(event: InputEvent) -> void:
    if (event.is_action_pressed("shoot") or event.is_action_pressed("shoot_alt") or event.is_action_pressed("dash") or event is InputEventJoypadButton) and health_component.is_dead() and can_continue_death:
        get_tree().reload_current_scene()
    if event is InputEventMouseMotion:
        mouse_position = event.position
    if event.is_action_pressed("dash"):
        state_machine.change_state(State.DASH)
    if event.is_action_released("dash"):
        state_machine.change_state(State.DEFAULT)


func get_aim_target_position() -> Vector2:
    var target_position: Vector2
    if GlobalInput.current_device == GlobalInput.Device.MOUSE:
        return mouse_position
    else:
        target_position = global_position + _control_aim_dir
    return target_position


func _normal_move(delta: float) -> void:
    _move(delta, wish_dir, ACCEL, SPEED, DECEL)


func _dash_enter() -> void:
    $DashStartSound.play()
    $DashParticles.emitting = true
    $DashLoopSound.play()
    $DashLoopSound.volume_linear = 0
    var tween = create_tween()
    tween.tween_property($DashLoopSound, "volume_linear", 1, 0.2)


func _dash_exit() -> void:
    $DashParticles.emitting = false
    var tween = create_tween()
    tween.tween_property($DashLoopSound, "volume_linear", 0, 0.2)
    tween.tween_callback(func(): $DashLoopSound.stop())


func _dash_move(delta: float) -> void:
    _move(delta, wish_dir, DASH_ACCEL, DASH_SPEED, DASH_DECEL)


func _move(delta: float, dir: Vector2, accel: float, speed: float, decel: float) -> void:
    if wish_dir:
        _accelerate(delta, accel, speed, dir)
    else:
        _decelerate(delta, decel)


func _decelerate(delta: float, decel: float) -> void:
    velocity = velocity.move_toward(Vector2.ZERO, decel * delta)


func _accelerate(delta: float, accel: float, speed: float, dir: Vector2) -> void:
    velocity += dir * accel * delta
    if velocity.length() > speed:
        velocity = velocity.limit_length(speed)


func _on_weapon_weapon_fired() -> void:
    velocity += global_position.direction_to(get_aim_target_position()).normalized() * -50
    GameCamera.shake(1, 100)
    $ShootSound.play()
    shoot_light.color.a = 1
    var tween := create_tween()
    tween.tween_property(shoot_light, "color:a", 0, 0.1)

const HERO_HURT_POOF = preload("uid://b4wc0xsl0jlwn")
const HERO_DEATH_POOF = preload("uid://mfe4sx0cbu3r")

func _on_health_component_damaged(amount: float, context: CombatContext) -> void:
    $HurtSound.play()

    GameCamera.shake(5, 20)

    $Sprite.modulate = Color("bfff3c") * 30
    var tween = create_tween()
    tween.tween_property($Sprite, "modulate", Color.WHITE, 0.1)

    var poof := HERO_HURT_POOF.instantiate() as Node2D
    poof.global_transform = global_transform
    get_node("/root/Main/Viewport/Game/SplatterLayer").add_child(poof)


func _dead_can_exit() -> bool:
    return false


func _dead_enter() -> void:
    collision_layer = 0
    collision_mask = 0

    $AimLine.hide()

    var poof := HERO_DEATH_POOF.instantiate() as Node2D
    poof.global_transform = global_transform
    get_node("/root/Main/Viewport/Game/SplatterLayer").add_child(poof)

    $WeaponAltAvailable.hide()

    $Sprite.hide()

    $DeathTimer.start()


func _on_health_component_killed() -> void:
    state_machine.change_state(State.DEAD)


func _on_death_timer_timeout() -> void:
    can_continue_death = true

const MESSAGE = preload("uid://c2fkfjo7ikued")

func say_message(msg: String) -> void:
    var msg_inst := MESSAGE.instantiate() as Node2D
    msg_inst.global_position = global_position + Vector2.UP * 16
    msg_inst.top_level = true
    msg_inst.text = msg
    add_child(msg_inst)


func _on_weapon_alt_weapon_fired() -> void:
    # TODO make weapon 1 not be able to fire for a bit too
    $WeaponAltAvailable.hide()


func _on_weapon_alt_weapon_available() -> void:
    if health_component.is_dead():
        return
    $WeaponAltAvailable.show()


enum Upgrade { 
    PELLETS,
    HEAL,
    ALT_BOUNCE,
    RANGE,
    VOLLEY,
}
var upgrade_count: Dictionary[Upgrade, int]
const FRIEND_ENCOUNTER = preload("uid://dpl1epvk051s2")
const FRIEND_SPAWN_POOF = preload("uid://cry31uu7sdsm7")

func _on_score_manager_levelled_up() -> void:
    #$LevelUpWeapon._shoot()
    spawner._do_spawn(FRIEND_ENCOUNTER)
    friend_signal()


func friend_signal() -> void:
    var poof := FRIEND_SPAWN_POOF.instantiate() as Node2D
    poof.global_transform = get_node("/root/Main/Viewport/Game/Ufo/SignalMarker").global_transform
    get_parent().add_child(poof)



func add_random_upgrade() -> void:
    $LevelUpSound.play()
    var all_ups := Upgrade.values()
    var valid_ups: Array[Upgrade]
    for u in all_ups:
        if u == Upgrade.PELLETS and check_upgrade_count(Upgrade.PELLETS, 2):
            continue
        if u == Upgrade.ALT_BOUNCE and check_upgrade_count(Upgrade.ALT_BOUNCE, 3):
            continue
        if u == Upgrade.RANGE and check_upgrade_count(Upgrade.RANGE, 2):
            continue
        if u == Upgrade.VOLLEY and check_upgrade_count(Upgrade.VOLLEY, 2):
            continue
        if u == Upgrade.HEAL and check_upgrade_count(Upgrade.HEAL, 5):
            continue
        valid_ups.append(u)

    var up = valid_ups.pick_random()
    if up == Upgrade.PELLETS:
        weapon.data.pellet_count += 1
        weapon.data.even_spread_angle += 4
        say_message("PELLETS+")
    if up == Upgrade.HEAL:
        health_component.max_health += 10
        say_message("HEALTH+")
    if up == Upgrade.ALT_BOUNCE:
        for p in weapon_alt._projectile_pool:
            p.max_bounces += 1
        say_message("BOUNCE+")
    if up == Upgrade.RANGE:
        for p in weapon._projectile_pool:
            p.max_distance += 35
        say_message("RANGE+")
    if up == Upgrade.VOLLEY:
        weapon_alt.data.volley_count += 1
        say_message("VOLLEY+")
    add_count(up)

    health_component.current_health += 25


func check_upgrade_count(up: Upgrade, max_up: int) -> bool:
    return upgrade_count.has(up) and upgrade_count[up] >= max_up

func add_count(up: Upgrade) -> void:
    if upgrade_count.has(up):
        upgrade_count[up] += 1
    else:
        upgrade_count[up] = 1
