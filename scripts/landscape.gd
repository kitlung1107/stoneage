extends Node3D
## Continuous cross-section: grass -> gentle bank -> shallow bed -> bank -> grass.
var tree_positions: Array[Vector3] = []

func _ready() -> void:
	name = "Landscape"
	var grass := ShaderMaterial.new()
	grass.shader = preload("res://shaders/grass.gdshader")
	var earth := StandardMaterial3D.new()
	earth.albedo_color = Color("90724d")
	var sections := [Vector2(-60, 0), Vector2(-7, 0), Vector2(-3, -0.65), Vector2(3, -0.65), Vector2(7, 0), Vector2(60, 0)]
	for i in range(sections.size() - 1):
		var a: Vector2 = sections[i]
		var b: Vector2 = sections[i + 1]
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		var vertices := [Vector3(a.x,a.y,-60),Vector3(b.x,b.y,-60),Vector3(a.x,a.y,60),Vector3(b.x,b.y,-60),Vector3(b.x,b.y,60),Vector3(a.x,a.y,60)]
		for vertex in vertices:
			surface.set_uv(Vector2((vertex.x + 60) / 120, (vertex.z + 60) / 120))
			surface.add_vertex(vertex)
		surface.generate_normals()
		var mesh := surface.commit()
		var body := StaticBody3D.new()
		var visual := MeshInstance3D.new()
		visual.mesh = mesh
		visual.material_override = grass if i == 0 or i == 4 else earth
		body.add_child(visual)
		var collision := CollisionShape3D.new()
		collision.shape = mesh.create_trimesh_shape()
		body.add_child(collision)
		add_child(body)
	var water := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(9.7, 120)
	water.mesh = plane
	water.position.y = -0.35
	var water_material := ShaderMaterial.new()
	water_material.shader = preload("res://shaders/river.gdshader")
	water.material_override = water_material
	add_child(water)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color("775138")
	var leaves := StandardMaterial3D.new()
	leaves.albedo_color = Color("427a30")
	# One tree per spaced cell, jittered; continuous clear crossing lane at z=6.
	for x in range(-54, 55, 9):
		for z in range(-54, 55, 9):
			var point := Vector3(x + rng.randf_range(-1.3,1.3), 0, z + rng.randf_range(-1.3,1.3))
			if absf(point.x) < 11 or absf(point.z - 6) < 4.5:
				continue
			var height := rng.randf_range(3.5, 5.0)
			tree_positions.append(point)
			var tree := StaticBody3D.new()
			tree.position = point
			add_child(tree)
			var trunk := BoxMesh.new()
			trunk.size = Vector3(0.65,height,0.65)
			add_part(tree,trunk,bark,Vector3(0,height/2,0))
			var collider := CollisionShape3D.new()
			var shape := BoxShape3D.new()
			shape.size = trunk.size
			collider.shape = shape
			collider.position.y = height/2
			tree.add_child(collider)
			for level in range(2):
				var crown := BoxMesh.new()
				crown.size = Vector3(3.5-level*0.9,1.6,3.5-level*0.9)
				add_part(tree,crown,leaves,Vector3(0,height+level*1.1,0))

func add_part(parent: Node3D, mesh: Mesh, material: Material, offset: Vector3) -> void:
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.material_override = material
	visual.position = offset
	parent.add_child(visual)
