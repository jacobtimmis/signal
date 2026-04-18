## Generic State Machine implementation.
## [br][br]
## Manages state with integer IDs mapped to [Callable]s.
## Associates functions with state IDs via [method setup_state].
## Can add arbitrary functions but some are built in: enter, exit and guards.
class_name StateMachine extends Object

const ENTER_CALLABLE := &"enter_callable"
const CAN_ENTER_CALLABLE := &"can_enter_callable"
const EXIT_CALLABLE := &"exit_callable"
const CAN_EXIT_CALLABLE := &"can_exit_callable"

## Current state ID.
var current_state: int
## Previous state ID.
var previous_state: int

## Display names of the states.
var _names: Dictionary[int, String]
## Dictionary of State ID (int) and CallableCollection pairs.
var _state_callables: Dictionary[int, CallableCollection]

## Add a state with a dictionary of StringName, Callable key-value pairs. E.g:
## [codeblock]
## state_machine.setup_state(State.NORMAL, {
##     ENTER_CALLABLE: _normal_enter,
##     EXIT_CALLABLE: _normal_exit,
## })
## [/codeblock]
## [b]Note[/b]: It is recommended to use enums as state IDs and StringName constants as keys.
func setup_state(state: int, callables: Dictionary[StringName, Callable], custom_name := "") -> void:
    _state_callables[state] = CallableCollection.new(callables)
    if not custom_name.is_empty():
        _names[state] = custom_name


## Sets the display names of states from a given enum.
func setup_names_from_enum(enumeration: Dictionary) -> void:
    for k in enumeration.keys() as Array[String]:
        _names[enumeration[k]] = k.capitalize()


## Transitions from the current state to the [param new_state]
## if the [member current_state] can be exited and the [param new_state] can be entered.
func change_state(new_state: int) -> void:
    if not can_exit_state(current_state) or not can_enter_state(new_state):
        return
    current_state_call_callable(EXIT_CALLABLE)
    previous_state = current_state
    current_state = new_state
    current_state_call_callable(ENTER_CALLABLE)


## Checks whether a given [param state] can be entered or not.
func can_enter_state(state: int) -> bool:
    if not _state_callables.has(state):
        return false
    if _state_callables[state].has_callable(CAN_ENTER_CALLABLE):
        return _state_callables[state].call_callable(CAN_ENTER_CALLABLE)
    else:
        return true


## Checks whether a given [param state] can be exited or not.
func can_exit_state(state: int) -> bool:
    if not _state_callables.has(state):
        return false
    if _state_callables[state].has_callable(CAN_EXIT_CALLABLE):
        return _state_callables[state].call_callable(CAN_EXIT_CALLABLE)
    else:
        return true


## Calls the current state's callable with the given [param id].
func current_state_call_callable(id: StringName, args := []) -> Variant:
    if _state_callables.has(current_state):
        return _state_callables[current_state].call_callable(id, args)
    else:
        return null


## Returns the name of the current state.
## If the given state does not have a name, this returns its ID as a string.
## [br] Use [method setup_state]'s  [param custom_name] parameter or
## [method setup_names_from_enum] to add display names.
func get_current_state_name() -> String:
    if _names.has(current_state):
        return _names[current_state]
    else:
        return str(current_state)


## Handles a dictionary with id, callable key-value pairs.
class CallableCollection:
    var _callables: Dictionary[StringName, Callable]

    ## Initialises a CallableCollection.
    func _init(i_callables: Dictionary[StringName, Callable]) -> void:
        _callables = i_callables

    ## Returns whether a callable with the given [param id] exists.
    func has_callable(id: StringName) -> bool:
        return _callables.has(id) and _callables[id]

    ## Calls the callable with the given [param id] (and optional [param args]) and returns its value.
    ## Returns [code]null[/code] if the callable does not exist.
    func call_callable(id: StringName, args := []) -> Variant:
        if has_callable(id):
            return _callables[id].callv(args)
        else:
            return null
