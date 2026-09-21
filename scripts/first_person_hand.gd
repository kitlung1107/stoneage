extends Node3D
## Approved artwork overlay, not a skeletal 3D hand.
var item_socket: Marker3D
var held_visual: Node3D
var view_camera: Camera3D
var hand_rect: TextureRect
var rest_position := Vector2.ZERO
var bob_phase := 0.0
var bob_weight := 0.0
var bob_offset := Vector2.ZERO
var bob_scale := 1.0

func _process(delta: float) -> void:
	var speed: float = view_camera.get_parent().walking_speed
	advance_bob(delta, speed)
	hand_rect.position = rest_position + bob_offset
	update_grip_position()

func advance_bob(delta: float, speed: float) -> void:
	var amount := clampf(speed / 4.0, 0.0, 1.0)
	# Exponential easing is consistent across frame rates, with a gentle stop.
	bob_weight = lerpf(bob_weight, amount, 1.0 - exp(-8.0 * delta))
	if amount > 0.01:
		bob_phase = fmod(bob_phase + TAU * 1.65 * sqrt(amount) * delta, TAU * 2.0)
	elif bob_weight < 0.001:
		bob_weight = 0.0
		bob_phase = 0.0
	# Downward-only excursion keeps the cropped forearm connected to screen bottom.
	bob_offset = Vector2(sin(bob_phase * 0.5) * 2.0, (1.0 - cos(bob_phase)) * 5.0) * bob_weight * bob_scale

func _ready() -> void:
	name = "FirstPersonHand"
	view_camera = get_parent() as Camera3D
	var layer := CanvasLayer.new()
	layer.layer = 0
	add_child(layer)
	hand_rect = TextureRect.new()
	hand_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var atlas := AtlasTexture.new()
	atlas.atlas = preload("res://assets/hand/approved-hand.png")
	atlas.region = Rect2(940, 600, 530, 424)
	hand_rect.texture = atlas
	hand_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/hand_cutout.gdshader")
	hand_rect.material = material
	layer.add_child(hand_rect)
	item_socket = Marker3D.new()
	item_socket.name = "ItemSocket"
	add_child(item_socket)
	get_viewport().size_changed.connect(update_screen_position)
	update_screen_position()

func update_screen_position() -> void:
	var screen := get_viewport().get_visible_rect().size
	var height := minf(screen.y * 0.40, screen.x * 0.60)
	hand_rect.size = Vector2(height * 530.0 / 424.0, height)
	rest_position = Vector2(screen.x - hand_rect.size.x - screen.x * 0.035, screen.y - height)
	bob_scale = height / 259.2
	hand_rect.position = rest_position + bob_offset
	update_grip_position()

func update_grip_position() -> void:
	var grip := hand_rect.position + hand_rect.size * Vector2(0.16, 0.20)
	position = view_camera.to_local(view_camera.project_position(grip, 0.65))

func clear_held_visual() -> void:
	if is_instance_valid(held_visual):
		item_socket.remove_child(held_visual)
		held_visual.queue_free()
	held_visual = null

## Cosmetic only; a null scene restores the empty hand.
func set_held_visual(scene: PackedScene) -> void:
	clear_held_visual()
	if scene == null:
		return
	var instance := scene.instantiate()
	if not instance is Node3D:
		instance.free()
		push_warning("Held visual must have a Node3D root")
		return
	held_visual = instance as Node3D
	item_socket.add_child(held_visual)
