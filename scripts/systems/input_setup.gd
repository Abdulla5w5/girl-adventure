extends Node

# Autoload "InputSetup".
# Registers all gameplay actions in code at startup, so project.godot stays
# free of fragile serialized InputEvent strings. Functionally identical to
# defining them in Project Settings > Input Map.
#
# To later edit a binding in the editor GUI instead, just add the same action
# name under Project Settings > Input Map and it will take precedence.

func _enter_tree() -> void:
	# action_name : { keys: [Key...], mouse: [MouseButton...],
	#                 pad_btn: [JoyButton...], pad_axis: [[axis, value]...] }
	var actions := {
		"move_forward":  { "keys": [KEY_W],     "pad_axis": [[JOY_AXIS_LEFT_Y, -1.0]] },
		"move_backward": { "keys": [KEY_S],     "pad_axis": [[JOY_AXIS_LEFT_Y,  1.0]] },
		"move_left":     { "keys": [KEY_A],     "pad_axis": [[JOY_AXIS_LEFT_X, -1.0]] },
		"move_right":    { "keys": [KEY_D],     "pad_axis": [[JOY_AXIS_LEFT_X,  1.0]] },
		"jump":          { "keys": [KEY_SPACE], "pad_btn": [JOY_BUTTON_A] },
		"run":           { "keys": [KEY_SHIFT], "pad_btn": [JOY_BUTTON_LEFT_STICK] },
		"roll":          { "keys": [KEY_Q],     "pad_btn": [JOY_BUTTON_B] },
		"crouch":        { "keys": [KEY_C],     "pad_btn": [JOY_BUTTON_RIGHT_SHOULDER] },
		"block":         { "keys": [KEY_F],     "pad_btn": [JOY_BUTTON_LEFT_SHOULDER] },
		"lock_on":       { "keys": [KEY_T],     "pad_btn": [JOY_BUTTON_RIGHT_STICK] },
		"inventory":     { "keys": [KEY_I],     "pad_btn": [JOY_BUTTON_BACK] },
		"interact":      { "keys": [KEY_E],     "pad_btn": [JOY_BUTTON_X] },
		"attack_light":  { "mouse": [MOUSE_BUTTON_LEFT],  "pad_axis": [[JOY_AXIS_TRIGGER_RIGHT, 1.0]] },
		"attack_heavy":  { "mouse": [MOUSE_BUTTON_RIGHT], "pad_axis": [[JOY_AXIS_TRIGGER_LEFT,  1.0]] },
		"cam_right":     { "pad_axis": [[JOY_AXIS_RIGHT_X,  1.0]] },
		"cam_left":      { "pad_axis": [[JOY_AXIS_RIGHT_X, -1.0]] },
		"cam_up":        { "pad_axis": [[JOY_AXIS_RIGHT_Y, -1.0]] },
		"cam_down":      { "pad_axis": [[JOY_AXIS_RIGHT_Y,  1.0]] },
	}

	for action_name in actions:
		if InputMap.has_action(action_name):
			continue  # respect any binding already defined in Project Settings
		InputMap.add_action(action_name, 0.2)
		var cfg: Dictionary = actions[action_name]

		for key in cfg.get("keys", []):
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action_name, ev)

		for btn in cfg.get("mouse", []):
			var ev := InputEventMouseButton.new()
			ev.button_index = btn
			InputMap.action_add_event(action_name, ev)

		for btn in cfg.get("pad_btn", []):
			var ev := InputEventJoypadButton.new()
			ev.button_index = btn
			InputMap.action_add_event(action_name, ev)

		for pair in cfg.get("pad_axis", []):
			var ev := InputEventJoypadMotion.new()
			ev.axis = pair[0]
			ev.axis_value = pair[1]
			InputMap.action_add_event(action_name, ev)
