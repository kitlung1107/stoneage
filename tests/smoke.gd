extends SceneTree

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func touch(controls: Control, index: int, pressed: bool, pos: Vector2) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.pressed = pressed
	event.position = pos
	controls._input(event)

func drag(controls: Control, index: int, pos: Vector2, relative: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = pos
	event.relative = relative
	controls._input(event)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var player = scene.get_node("Player")
	var controls = scene.get_node("Interface/Controls")
	check(player.hand.hand_rect.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Hand overlay must not intercept touch input")
	var sample := Node3D.new()
	var packed := PackedScene.new()
	packed.pack(sample)
	sample.free()
	player.hand.set_held_visual(packed)
	check(player.hand.held_visual.get_parent() == player.hand.item_socket, "Held visual must attach to grip")
	player.hand.set_held_visual(null)
	check(player.hand.held_visual == null and player.hand.item_socket.get_child_count() == 0, "Clearing must return to empty hand")
	for i in range(60):
		await physics_frame
	check(player.is_on_floor(), "Player must land on grass")
	check(absf(player.position.y) < 0.05, "Feet must rest on ground")
	var right := Vector2(controls.size.x * 0.75, 250)
	touch(controls, 4, true, Vector2(100, 250))
	touch(controls, 9, true, right)
	drag(controls, 4, Vector2(100, 190), Vector2(0, -60))
	var before: Vector3 = player.position
	var yaw: float = player.rotation.y
	drag(controls, 9, right + Vector2(50, 0), Vector2(50, 0))
	for i in range(20):
		await physics_frame
	check(player.position.distance_to(before) > 0.1, "Left touch must move while right touch looks")
	check(player.rotation.y != yaw, "Right touch must turn camera")
	touch(controls, 9, false, right)
	check(player.move_input.length() > 0, "Releasing look must retain movement")
	touch(controls, 4, false, Vector2.ZERO)
	check(player.move_input == Vector2.ZERO, "Releasing movement must stop")
	player.look(Vector2(0, 10000))
	check(absf(player.camera.rotation.x) <= deg_to_rad(80.01), "Pitch must be clamped")
	player.look(Vector2(0, -20000))
	check(absf(player.camera.rotation.x) <= deg_to_rad(80.01), "Opposite pitch must be clamped")
	touch(controls, 1, true, Vector2(100, 250))
	drag(controls, 1, Vector2(160, 250), Vector2(60, 0))
	controls.reset_touches()
	check(controls.move_id == -1 and controls.look_id == -1 and player.move_input == Vector2.ZERO, "Resize/focus reset must clear touches")
	player.position.x = 59
	await physics_frame
	await physics_frame
	check(player.position.x <= 58, "Player must remain on ground boundary")
	print("PHASE_ONE_TESTS: ", "PASS" if failures == 0 else "FAIL", " (", failures, " failures)")
	quit(failures)
