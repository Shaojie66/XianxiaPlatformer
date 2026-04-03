extends CharacterBody2D

class_name SummonBase

enum SummonType {
	SWORD_SPIRIT,
	SPIRIT_GRASS,
	ICE_PHOENIX,
	FIRE_CROW,
	STONE_GOLEM,
	SHADOW_DEMON,
	SUN_GOD,
	YIN_YANG_BEAST,
	IMMORTAL_BEAST,
}

enum Element {
	METAL,
	WOOD,
	WATER,
	FIRE,
	EARTH,
	YIN,
	YANG,
	YIN_YANG,
	FIVE_ELEMENTS,
}

@export var summon_type: SummonType = SummonType.SWORD_SPIRIT
@export var element: Element = Element.METAL
@export var damage: int = 10
@export var effect_radius: float = 96.0
@export var lifetime: float = 10.0
@export var is_active: bool = false

var summoner: Node2D = null
var hover_height: float = -36.0
var orbit_distance: float = 44.0
var follow_lerp_speed: float = 8.0
var effect_interval: float = 1.0
var _effect_timer: float = 0.0


func activate(caller: Node2D) -> void:
	summoner = caller
	is_active = true
	_effect_timer = 0.0
	set_physics_process(true)
	if summoner != null:
		global_position = summoner.global_position + Vector2(orbit_distance, hover_height)


func deactivate() -> void:
	is_active = false
	set_physics_process(false)
	queue_free()


func _physics_process(delta: float) -> void:
	if not is_active:
		return

	lifetime = maxf(lifetime - delta, 0.0)
	if lifetime <= 0.0:
		deactivate()
		return

	_follow_summoner(delta)

	_effect_timer -= delta
	if _effect_timer > 0.0:
		return

	_effect_timer = effect_interval
	var targets: Array[Node2D] = _get_targets_in_radius()
	for target in targets:
		apply_effect(target)


func apply_effect(target: Node2D) -> void:
	pass


func _follow_summoner(delta: float) -> void:
	if not is_instance_valid(summoner):
		return

	var side: float = -1.0 if _is_owner_facing_left() else 1.0
	var target_position := summoner.global_position + Vector2(orbit_distance * side, hover_height)
	global_position = global_position.lerp(target_position, clampf(follow_lerp_speed * delta, 0.0, 1.0))


func _get_targets_in_radius() -> Array[Node2D]:
	var targets: Array[Node2D] = []
	var tree := get_tree()
	if tree == null:
		return targets

	for node in tree.get_nodes_in_group("enemies"):
		if node is Node2D and is_instance_valid(node):
			var enemy := node as Node2D
			if global_position.distance_to(enemy.global_position) <= effect_radius:
				targets.append(enemy)

	return targets


func _get_allies_in_radius() -> Array[Node2D]:
	var allies: Array[Node2D] = []
	if is_instance_valid(summoner):
		allies.append(summoner)

	var tree := get_tree()
	if tree == null:
		return allies

	for node in tree.get_nodes_in_group("allies"):
		if node is Node2D and node != summoner and is_instance_valid(node):
			var ally := node as Node2D
			if global_position.distance_to(ally.global_position) <= effect_radius:
				allies.append(ally)

	return allies


func _is_owner_facing_left() -> bool:
	if not is_instance_valid(summoner):
		return false

	if "facing_direction" in summoner:
		return int(summoner.get("facing_direction")) < 0

	return false


func _deal_damage(target: Node2D, amount: int) -> void:
	if target == null or amount <= 0:
		return

	if target.has_method("take_damage"):
		target.call("take_damage", amount)
		return

	if "stats" in target:
		var stats: Variant = target.get("stats")
		if stats != null and stats.has_method("take_damage"):
			stats.call("take_damage", amount)


func _heal_target(target: Node2D, amount: int) -> void:
	if target == null or amount <= 0:
		return

	if target.has_method("heal"):
		target.call("heal", amount)
		return

	if "stats" in target:
		var stats: Variant = target.get("stats")
		if stats != null and stats.has_method("heal"):
			stats.call("heal", amount)


func _apply_status(target: Node2D, status_name: StringName, value: Variant) -> void:
	if target == null:
		return

	if target.has_method("apply_status"):
		target.call("apply_status", status_name, value)
		return

	if target.has_method(str(status_name)):
		target.call(str(status_name), value)
		return

	target.set_meta(status_name, value)


class SwordSpiritSummon extends SummonBase:
	func _init() -> void:
		summon_type = SummonType.SWORD_SPIRIT
		element = Element.METAL
		damage = 18
		effect_radius = 240.0
		effect_interval = 0.75

	func apply_effect(target: Node2D) -> void:
		if target == null:
			return
		_deal_damage(target, damage)


class SpiritGrassSummon extends SummonBase:
	var _heal_timer: float = 0.0

	func _init() -> void:
		summon_type = SummonType.SPIRIT_GRASS
		element = Element.WOOD
		damage = 0
		effect_radius = 140.0
		effect_interval = 1.25

	func apply_effect(target: Node2D) -> void:
		pass

	func _physics_process(delta: float) -> void:
		super._physics_process(delta)
		if not is_active:
			return

		_heal_timer -= delta
		if _heal_timer <= 0.0:
			_heal_timer = 1.25
			for ally in _get_allies_in_radius():
				_heal_target(ally, 8)


class IcePhoenixSummon extends SummonBase:
	func _init() -> void:
		summon_type = SummonType.ICE_PHOENIX
		element = Element.WATER
		damage = 14
		effect_radius = 160.0
		effect_interval = 1.0

	func apply_effect(target: Node2D) -> void:
		_deal_damage(target, damage)
		_apply_status(target, &"freeze", 1.5)


class FireCrowSummon extends SummonBase:
	func _init() -> void:
		summon_type = SummonType.FIRE_CROW
		element = Element.FIRE
		damage = 16
		effect_radius = 172.0
		effect_interval = 0.9

	func apply_effect(target: Node2D) -> void:
		_deal_damage(target, damage)
		_apply_status(target, &"burn", 2.0)


class StoneGolemSummon extends SummonBase:
	func _init() -> void:
		summon_type = SummonType.STONE_GOLEM
		element = Element.EARTH
		damage = 8
		effect_radius = 190.0
		effect_interval = 1.0
		hover_height = 0.0
		orbit_distance = 28.0

	func apply_effect(target: Node2D) -> void:
		_apply_status(target, &"taunt", summoner)
		_deal_damage(target, damage)


class ShadowDemonSummon extends SummonBase:
	func _init() -> void:
		summon_type = SummonType.SHADOW_DEMON
		element = Element.YIN
		damage = 24
		effect_radius = 150.0
		effect_interval = 0.65

	func apply_effect(target: Node2D) -> void:
		_deal_damage(target, damage)
		_apply_status(target, &"shadow_mark", 3.0)


class SunGodSummon extends SummonBase:
	var _heal_timer: float = 0.0

	func _init() -> void:
		summon_type = SummonType.SUN_GOD
		element = Element.YANG
		damage = 0
		effect_radius = 180.0
		effect_interval = 1.0

	func apply_effect(target: Node2D) -> void:
		pass

	func _physics_process(delta: float) -> void:
		super._physics_process(delta)
		if not is_active:
			return

		_heal_timer -= delta
		if _heal_timer <= 0.0:
			_heal_timer = 1.0
			for ally in _get_allies_in_radius():
				_heal_target(ally, 12)
				_apply_status(ally, &"radiance", 1.5)


class YinYangBeastSummon extends SummonBase:
	func _init() -> void:
		summon_type = SummonType.YIN_YANG_BEAST
		element = Element.YIN_YANG
		damage = 22
		effect_radius = 180.0
		effect_interval = 0.8

	func apply_effect(target: Node2D) -> void:
		_deal_damage(target, damage)
		_apply_status(target, &"freeze", 0.5)
		if is_instance_valid(summoner):
			_heal_target(summoner, 6)


class ImmortalBeastSummon extends SummonBase:
	func _init() -> void:
		summon_type = SummonType.IMMORTAL_BEAST
		element = Element.FIVE_ELEMENTS
		damage = 28
		effect_radius = 220.0
		effect_interval = 0.7

	func apply_effect(target: Node2D) -> void:
		_deal_damage(target, damage)
		_apply_status(target, &"freeze", 0.75)
		_apply_status(target, &"burn", 2.5)
		_apply_status(target, &"shadow_mark", 2.5)
		_apply_status(target, &"taunt", summoner)
		for ally in _get_allies_in_radius():
			_heal_target(ally, 10)
