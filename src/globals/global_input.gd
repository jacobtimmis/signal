## Handle global input and gui stuff.
extends Node

## Emitted when the player enters an input on a device that is different to the last device used.
signal input_device_changed(old_device: Device)

## Type of device a player can use.
enum Device {
    MOUSE,
    JOYPAD,
}

const KEYS_TO_IGNORE = [
    KEY_SHIFT,
    KEY_ALT,
    KEY_META,
    KEY_CTRL,
    KEY_ESCAPE,
    KEY_F1,
    KEY_F2,
    KEY_F3,
    KEY_F4,
    KEY_F5,
    KEY_F6,
    KEY_F7,
    KEY_F8,
    KEY_F9,
    KEY_F10,
    KEY_F11,
    KEY_F12,
]

var current_device := Device.MOUSE
var default_control_to_focus: Control
var _skip_device_detection := false


func _ready() -> void:
    # Assume the player wants to use a joypad if one is connected
    var joypad_count := Input.get_connected_joypads().size()
    print("%s connected joypad(s)" % joypad_count)
    if joypad_count > 0:
        _set_current_device(Device.JOYPAD)


func _input(event: InputEvent) -> void:
    _detect_device(event)

    if event.is_action_pressed("toggle_fullscreen") and not OS.has_environment("web"):
        var window_mode := DisplayServer.window_get_mode()
        if window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or window_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
            window_mode = DisplayServer.WINDOW_MODE_WINDOWED
        else:
            window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
        DisplayServer.window_set_mode(window_mode)
        # Hack: skip the next input because it would be a very large mouse motion
        # which we don't want to consider for device detection.
        _skip_device_detection = true


func skip_device_detection() -> void:
    _skip_device_detection = true


## Set mouse mode to visible.
func show_mouse() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


## Sets mouse mode to hidden.
func hide_mouse() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


## Whether the last device used was a joypad or not.
func is_joypad() -> bool:
    return current_device == Device.JOYPAD


## Whether the last device used was a mouse or not.
func is_mouse() -> bool:
    return current_device == Device.MOUSE


## Whether the player's input should be used or not.
func can_input() -> bool:
    return true


func _should_ignore_input_event_key(event: InputEventKey) -> bool:
    return event.get_modifiers_mask() != 0 or event.keycode in KEYS_TO_IGNORE


func _detect_device(event: InputEvent) -> void:
    # Discard any motion events that are too small.
    if event is InputEventJoypadMotion and abs(event.axis_value) < 0.1:
        return
    if event is InputEventMouseMotion and event.relative.length() < 0.1:
        return

    if _skip_device_detection:
        _skip_device_detection = false
        return

    # Set device depending on input event.
    if event is InputEventMouse:
        _set_current_device(Device.MOUSE)
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        _set_current_device(Device.JOYPAD)


func _set_current_device(new_device: Device) -> void:
    var old_device := current_device

    # We do not care if the device is the same.
    if new_device == current_device:
        return

    current_device = new_device
    get_viewport().set_input_as_handled()

    print("Input device changed to %s" % Device.keys()[current_device])

    input_device_changed.emit(old_device)

    if is_mouse():
        show_mouse()
        # Hide the current focus, as visual focus is not for mouse input.
        if get_viewport().gui_get_focus_owner():
            get_viewport().gui_get_focus_owner().grab_focus(true)
    else:
        hide_mouse()
        if default_control_to_focus:
            default_control_to_focus.grab_focus()
        else:
            push_warning("No default_control_to_focus for us to grab!")


func set_default_control_to_focus(control: Control) -> void:
    if not control:
        return
    if not control.is_inside_tree():
        push_warning("Cannot set default_control_to_focus as %s is outside tree." % control.name)
        return
    default_control_to_focus = control
    control.grab_focus(is_mouse())
