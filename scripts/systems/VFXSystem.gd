extends Node

class_name VFXSystem

const VFX_PATH: String = "res://assets/vfx/"

enum VFXType {
	HIT,
	HEAL,
	ELEMENTAL_IMPACT,
	DASH_TRAIL,
	DEATH,
}


static func spawn_vfx(vfx_type: VFXType, position: Vector2, parent: Node = null) -> void:
	var vfx_node := _create_vfx_node(vfx_type)
	vfx_node.global_position = position

	var target_parent: Node = Engine.get_main_loop().root
	if parent != null:
		target_parent = parent
	target_parent.add_child(vfx_node)

	vfx_node.tree_exited.connect(func(): pass)


static func _create_vfx_node(vfx_type: VFXType) -> Node2D:
	match vfx_type:
		VFXType.HIT:
			return _create_hit_vfx()
		VFXType.HEAL:
			return _create_heal_vfx()
		VFXType.ELEMENTAL_IMPACT:
			return _create_elemental_vfx()
		VFXType.DASH_TRAIL:
			return _create_dash_trail_vfx()
		VFXType.DEATH:
			return _create_death_vfx()
		_:
			return _create_hit_vfx()


static func _create_hit_vfx() -> Node2D:
	var container := Node2D.new()
	var particles := GPUParticles2D.new()
	particles.amount = 16
	particles.lifetime = 0.3
	particles.explosiveness = 0.8
	particles.randomness = 1.0
	particles.process_material = _create_hit_material()
	container.add_child(particles)
	return container


static func _create_heal_vfx() -> Node2D:
	var container := Node2D.new()
	var particles := GPUParticles2D.new()
	particles.amount = 12
	particles.lifetime = 0.8
	particles.explosiveness = 0.3
	particles.process_material = _create_heal_material()
	container.add_child(particles)
	return container


static func _create_elemental_vfx() -> Node2D:
	var container := Node2D.new()
	var particles := GPUParticles2D.new()
	particles.amount = 24
	particles.lifetime = 0.5
	particles.explosiveness = 0.6
	particles.process_material = _create_elemental_material()
	container.add_child(particles)
	return container


static func _create_dash_trail_vfx() -> Node2D:
	var container := Node2D.new()
	var particles := GPUParticles2D.new()
	particles.amount = 8
	particles.lifetime = 0.2
	particles.explosiveness = 0.2
	particles.process_material = _create_trail_material()
	container.add_child(particles)
	return container


static func _create_death_vfx() -> Node2D:
	var container := Node2D.new()
	var particles := GPUParticles2D.new()
	particles.amount = 32
	particles.lifetime = 1.0
	particles.explosiveness = 0.9
	particles.process_material = _create_death_material()
	container.add_child(particles)
	return container


static func _create_hit_material() -> ParticleProcessMaterial:
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(1, 1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 100.0
	mat.initial_velocity_max = 200.0
	mat.gravity = Vector3(0, 300, 0)
	mat.color = Color(1.0, 0.3, 0.1, 1.0)
	return mat


static func _create_heal_material() -> ParticleProcessMaterial:
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 60.0
	mat.initial_velocity_min = 50.0
	mat.initial_velocity_max = 100.0
	mat.gravity = Vector3(0, -200, 0)
	mat.color = Color(0.3, 1.0, 0.3, 1.0)
	return mat


static func _create_elemental_material() -> ParticleProcessMaterial:
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(1, 1, 0)
	mat.spread = 120.0
	mat.initial_velocity_min = 150.0
	mat.initial_velocity_max = 300.0
	mat.gravity = Vector3(0, 200, 0)
	mat.color = Color(0.5, 0.8, 1.0, 1.0)
	return mat


static func _create_trail_material() -> ParticleProcessMaterial:
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(1, 0, 0)
	mat.spread = 30.0
	mat.initial_velocity_min = 30.0
	mat.initial_velocity_max = 60.0
	mat.gravity = Vector3(0, 0, 0)
	mat.color = Color(0.8, 0.8, 1.0, 0.6)
	return mat


static func _create_death_material() -> ParticleProcessMaterial:
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(1, 1, 0)
	mat.spread = 360.0
	mat.initial_velocity_min = 200.0
	mat.initial_velocity_max = 400.0
	mat.gravity = Vector3(0, 500, 0)
	mat.color = Color(0.8, 0.2, 0.2, 1.0)
	return mat


static func spawn_hit_at(position: Vector2, parent: Node = null) -> void:
	spawn_vfx(VFXType.HIT, position, parent)


static func spawn_heal_at(position: Vector2, parent: Node = null) -> void:
	spawn_vfx(VFXType.HEAL, position, parent)


static func spawn_elemental_at(position: Vector2, parent: Node = null) -> void:
	spawn_vfx(VFXType.ELEMENTAL_IMPACT, position, parent)
