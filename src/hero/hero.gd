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

@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
    inst = self

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

    $DashParticles.emitting = false


func _process(_delta: float) -> void:
    if health_component.is_dead():
        return

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

const HERO_HURT_POOF = preload("uid://b4wc0xsl0jlwn")
const HERO_DEATH_POOF = preload("uid://mfe4sx0cbu3r")

func _on_health_component_damaged(amount: float, context: CombatContext) -> void:
    $HurtSound.play()

    GameCamera.shake(5, 20)

    $Sprite.modulate = Color("bfff3c") * 30
    var tween = create_tween()
    tween.tween_property($Sprite, "modulate", Color.WHITE, 0.1)

    var inst := HERO_HURT_POOF.instantiate() as Node2D
    inst.global_transform = global_transform
    get_node("/root/Main/Viewport/Game/SplatterLayer").add_child(inst)


func _dead_can_exit() -> bool:
    return false


func _dead_enter() -> void:
    collision_layer = 0
    collision_mask = 0

    $AimLine.hide()

    var inst := HERO_DEATH_POOF.instantiate() as Node2D
    inst.global_transform = global_transform
    get_node("/root/Main/Viewport/Game/SplatterLayer").add_child(inst)

    $Sprite.hide()

    $DeathTimer.start()


func _on_health_component_killed() -> void:
    state_machine.change_state(State.DEAD)


func _on_death_timer_timeout() -> void:
    get_tree().reload_current_scene()
