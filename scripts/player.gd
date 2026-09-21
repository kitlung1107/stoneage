extends CharacterBody3D

const SPEED := 4.0
const LOOK_LIMIT := deg_to_rad(80.0)
var move_input := Vector2.ZERO
var camera: Camera3D
var hand: Node3D

func _ready() -> void:
	camera = Camera3D.new()
	camera.position.y = 1.6
	camera.fov = 75.0
	camera.far = 180.0
	add_child(camera)
	camera.current = true
	hand = preload("res://scripts/first_person_hand.gd").new()
	camera.add_child(hand)
	var shape := CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = 1.8
	var collider := CollisionShape3D.new()
	collider.shape = shape
	collider.position.y = 0.9
	add_child(collider)

func look(delta: Vector2) -> void:
	rotate_y(-delta.x)
	camera.rotation.x = clampf(camera.rotation.x - delta.y, -LOOK_LIMIT, LOOK_LIMIT)

func _physics_process(delta: float) -> void:
	var keys := Vector2.ZERO
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		keys = Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)), float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	var axis := (move_input + keys).limit_length()
	var direction := transform.basis * Vector3(axis.x, 0, axis.y)
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0
	move_and_slide()
	# Keep the learner on the finite grassland without invisible scenery.
	position.x = clampf(position.x, -58.0, 58.0)
	position.z = clampf(position.z, -58.0, 58.0)
	if position.y < -10:
		position = Vector3(0, 0.2, 0)
		velocity = Vector3.ZERO
