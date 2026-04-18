extends CharacterBody2D

enum State { DEFAULT, DASH }

const SPEED = 70.0
const ACCEL = 1000.0
const DECEL = 1000.0
const MOVE_CALLABLE = &"move"
const DASH_DURATION = 0.2
const DASH_ACCEL = 2000
const CONTROL_AIM_DEADZONE = 0.5

var state_machine := StateMachine.new()
var wish_dir: Vector2
var dash_dir: Vector2
var dash_time: float
var _control_aim_dir := Vector2.RIGHT


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
            MOVE_CALLABLE: _dash_move,
        },
    )
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

func _physics_process(delta: float) -> void:
    wish_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    state_machine.current_state_call_callable(MOVE_CALLABLE, [delta])

    move_and_slide()


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("dash"):
        state_machine.change_state(State.DASH)


func _normal_move(delta: float) -> void:
    if wish_dir:
        _accelerate(delta, ACCEL, SPEED)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, DECEL * delta)


func _dash_enter() -> void:
    dash_dir = wish_dir.normalized()
    dash_time = DASH_DURATION


func _dash_move(delta: float) -> void:
    dash_time -= delta
    if dash_time <= 0:
        state_machine.change_state(State.DEFAULT)
    _accelerate(delta, DASH_ACCEL, DASH_SPEED)


func _accelerate(delta: float, accel: float, speed: float) -> void:
    velocity += wish_dir * accel * delta
    if velocity.length() > speed:
        velocity = velocity.limit_length(speed)
