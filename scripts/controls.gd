extends Control

var player: CharacterBody3D
var move_id := -1
var look_id := -1
var origin := Vector2.ZERO
var knob := Vector2.ZERO
var radius := 65.0
var touch_active := false
var hint: Label
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_active = DisplayServer.is_touchscreen_available()
	hint = Label.new()
	hint.add_theme_font_override("font", preload("res://assets/fonts/NotoSansTC.ttf"))
	hint.text = "第一階段：草地探索\n左側拖動行走　右側拖動觀看" if touch_active else "第一階段：草地探索\n按一下開始｜WASD／方向鍵行走\n滑鼠觀看｜Esc 釋放滑鼠"
	hint.position = Vector2(20, 18)
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	hint.add_theme_constant_override("shadow_offset_x", 1)
	hint.add_theme_constant_override("shadow_offset_y", 2)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)
	get_viewport().size_changed.connect(reset_touches)

func reset_touches() -> void:
	move_id = -1
	look_id = -1
	player.move_input = Vector2.ZERO
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(player):
		reset_touches()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		touch_active = true
		hint.text = "第一階段：草地探索\n左側拖動行走　右側拖動觀看"
		if event.pressed and not event.canceled:
			if event.position.x < size.x * 0.5 and move_id == -1:
				move_id = event.index
				origin = event.position
				knob = origin
			elif event.position.x >= size.x * 0.5 and look_id == -1:
				look_id = event.index
		else:
			if event.index == move_id:
				move_id = -1
				player.move_input = Vector2.ZERO
			if event.index == look_id:
				look_id = -1
		queue_redraw()
	elif event is InputEventScreenDrag:
		if event.index == move_id:
			var offset: Vector2 = (event.position - origin).limit_length(radius)
			knob = origin + offset
			player.move_input = offset / radius if offset.length() > 7 else Vector2.ZERO
		elif event.index == look_id:
			player.look(event.relative * (2.4 / maxf(size.y, 320)))
		queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player.look(event.relative * 0.0025)
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		reset_touches()

func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, 2.5, Color(1, 1, 1, 0.85))
	if touch_active:
		var base := origin if move_id != -1 else Vector2(105, size.y - 110)
		draw_circle(base, radius, Color(0.06, 0.15, 0.08, 0.25))
		draw_arc(base, radius, 0, TAU, 48, Color(1, 1, 1, 0.5), 2, true)
		draw_circle(knob if move_id != -1 else base, 24, Color(1, 1, 1, 0.45))

