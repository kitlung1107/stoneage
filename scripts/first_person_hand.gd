extends Node3D
## Approved artwork overlay, not a skeletal 3D hand.
var item_socket: Marker3D
var held_visual: Node3D
var view_camera: Camera3D
var hand_rect: TextureRect

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
	hand_rect.position = Vector2(screen.x - hand_rect.size.x - screen.x * 0.035, screen.y - height)
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
