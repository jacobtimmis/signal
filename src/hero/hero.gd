class_name Hero
extends CharacterBody2D

enum State { DEFAULT, DASH }

const MOVE_CALLABLE = &"move"
const SPEED = 70.0
const ACCEL = 1000.0
const DECEL = 400.0
const DASH_ACCEL = 1000.0
const DASH_SPEED = 140.0
const DASH_DECEL = 300.0
const CONTROL_AIM_DEADZONE = 0.5

var state_machine := StateMachine.new()
var wish_dir: Vector2
var last_non_zero_wish_dir: Vector2
var dash_dir: Vector2
var dash_time: float
var _control_aim_dir := Vector2.RIGHT
@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
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
    state_machine.setup_names_from_enum(State)

    $DashParticles.emitting = false



func _process(delta: float) -> void:
    var current_aim_dir := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
    if current_aim_dir.length() > CONTROL_AIM_DEADZONE:
        _control_aim_dir = current_aim_dir
        _control_aim_dir = _control_aim_dir.normalized()

    var target_position: Vector2
    if GlobalInput.current_device == GlobalInput.Device.MOUSE:
        target_position = get_global_mouse_position()
    else:
        target_position = global_position + _control_aim_dir

    $AimLine.target_position = target_position
    $Weapon.target_position = target_position
    if Input.is_action_pressed("shoot"):
        $Weapon._shoot()

func _physics_process(delta: float) -> void:
    wish_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    wish_dir = wish_dir.normalized()

    if wish_dir.length() != 0:
        last_non_zero_wish_dir = wish_dir

    state_machine.current_state_call_callable(MOVE_CALLABLE, [delta])

    move_and_slide()


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("dash"):
        state_machine.change_state(State.DASH)
    if event.is_action_released("dash"):
        state_machine.change_state(State.DEFAULT)


func _normal_move(delta: float) -> void:
    _move(delta, wish_dir, ACCEL, SPEED, DECEL)


func _dash_enter() -> void:
    $DashStartSound.play()
    $DashParticles.emitting = true


func _dash_exit() -> void:
    $DashParticles.emitting = false


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
    $ShootSound.play()
