extends Node

class_name SummonSystem

const SummonBaseScript = preload("res://scripts/characters/SummonBase.gd")

signal summon_called(summon_type: SummonBaseScript.SummonType)
signal summon_cancelled()
signal summon_expired()

const REALM_ORDER: Array[String] = [
	"炼气",
	"筑基",
	"金丹",
	"元婴",
	"化神",
	"大乘",
	"渡劫",
	"地仙",
	"天仙",
]

const SUMMON_REALM_REQUIREMENTS: Dictionary = {
	SummonBaseScript.SummonType.SWORD_SPIRIT: "炼气",
	SummonBaseScript.SummonType.SPIRIT_GRASS: "筑基",
	SummonBaseScript.SummonType.ICE_PHOENIX: "金丹",
	SummonBaseScript.SummonType.FIRE_CROW: "元婴",
	SummonBaseScript.SummonType.STONE_GOLEM: "化神",
	SummonBaseScript.SummonType.SHADOW_DEMON: "大乘",
	SummonBaseScript.SummonType.SUN_GOD: "渡劫",
	SummonBaseScript.SummonType.YIN_YANG_BEAST: "地仙",
	SummonBaseScript.SummonType.IMMORTAL_BEAST: "天仙",
}

var SUMMON_FACTORIES: Dictionary = {
	SummonBaseScript.SummonType.SWORD_SPIRIT: func() -> SummonBase: return SummonBaseScript.SwordSpiritSummon.new(),
	SummonBaseScript.SummonType.SPIRIT_GRASS: func() -> SummonBase: return SummonBaseScript.SpiritGrassSummon.new(),
	SummonBaseScript.SummonType.ICE_PHOENIX: func() -> SummonBase: return SummonBaseScript.IcePhoenixSummon.new(),
	SummonBaseScript.SummonType.FIRE_CROW: func() -> SummonBase: return SummonBaseScript.FireCrowSummon.new(),
	SummonBaseScript.SummonType.STONE_GOLEM: func() -> SummonBase: return SummonBaseScript.StoneGolemSummon.new(),
	SummonBaseScript.SummonType.SHADOW_DEMON: func() -> SummonBase: return SummonBaseScript.ShadowDemonSummon.new(),
	SummonBaseScript.SummonType.SUN_GOD: func() -> SummonBase: return SummonBaseScript.SunGodSummon.new(),
	SummonBaseScript.SummonType.YIN_YANG_BEAST: func() -> SummonBase: return SummonBaseScript.YinYangBeastSummon.new(),
	SummonBaseScript.SummonType.IMMORTAL_BEAST: func() -> SummonBase: return SummonBaseScript.ImmortalBeastSummon.new(),
}

@export var max_summons: int = 1
@export var cooldown: float = 5.0
@export var summon_duration: float = 10.0

var _active_summons: Array[SummonBase] = []
var _unlocked_summons: Dictionary = {}
var _cooldown_remaining: float = 0.0


func _ready() -> void:
	set_process(true)
	add_to_group("summon_system")
	_unlock_starting_summons()


func _process(delta: float) -> void:
	if _cooldown_remaining > 0.0:
		_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)
	_process_summon_effects(delta)


func call_summon(summon_type: SummonBaseScript.SummonType) -> void:
	if not is_summon_ready(summon_type):
		return

	var caller := _find_player()
	if caller == null:
		push_warning("SummonSystem could not find a player node to own the summon.")
		return

	if _active_summons.size() >= max_summons:
		cancel_summon()

	var summon := _create_summon_instance(summon_type)
	if summon == null:
		push_warning("SummonSystem could not create summon instance for type %s." % [summon_type])
		return

	var current_scene := get_tree().current_scene
	if current_scene == null:
		push_warning("SummonSystem could not find the active scene to attach summons.")
		return

	current_scene.add_child(summon)
	summon.lifetime = summon_duration
	summon.activate(caller)
	_active_summons.append(summon)
	_cooldown_remaining = cooldown
	summon_called.emit(summon_type)


func cancel_summon() -> void:
	if _active_summons.is_empty():
		return

	for summon in _active_summons:
		if is_instance_valid(summon):
			summon.deactivate()

	_active_summons.clear()
	summon_cancelled.emit()


func is_summon_ready(summon_type: SummonBaseScript.SummonType) -> bool:
	return _unlocked_summons.get(summon_type, false) and _cooldown_remaining <= 0.0


func unlock_summon(summon_type: SummonBaseScript.SummonType) -> void:
	_unlocked_summons[summon_type] = true


func unlock_summons_for_realm(realm_name: String) -> void:
	var realm_index: int = REALM_ORDER.find(realm_name)
	if realm_index == -1:
		return

	for summon_type in SUMMON_REALM_REQUIREMENTS.keys():
		var required_realm: String = SUMMON_REALM_REQUIREMENTS[summon_type]
		var required_index: int = REALM_ORDER.find(required_realm)
		if required_index != -1 and required_index <= realm_index:
			unlock_summon(summon_type)


func get_active_summons() -> Array[SummonBase]:
	_active_summons = _active_summons.filter(func(summon: SummonBase) -> bool: return is_instance_valid(summon))
	return _active_summons.duplicate()


func _process_summon_effects(_delta: float) -> void:
	var expired_any := false
	var alive_summons: Array[SummonBase] = []

	for summon in _active_summons:
		if not is_instance_valid(summon):
			expired_any = true
			continue

		if not summon.is_active or summon.lifetime <= 0.0:
			if is_instance_valid(summon):
				summon.deactivate()
			expired_any = true
			continue

		alive_summons.append(summon)

	_active_summons = alive_summons

	if expired_any and _active_summons.is_empty():
		summon_expired.emit()


func _unlock_starting_summons() -> void:
	unlock_summon(SummonBaseScript.SummonType.SWORD_SPIRIT)


func _create_summon_instance(summon_type: SummonBaseScript.SummonType) -> SummonBase:
	var factory: Callable = SUMMON_FACTORIES.get(summon_type, Callable())
	if factory.is_null():
		return null
	return factory.call()


func _find_player() -> Node2D:
	var tree := get_tree()
	if tree == null:
		return null

	var players: Array[Node] = tree.get_nodes_in_group("player")
	for node in players:
		if node is Node2D and is_instance_valid(node):
			return node as Node2D

	if tree.current_scene == null:
		return null

	return _find_first_player_node(tree.current_scene)


func _find_first_player_node(node: Node) -> Node2D:
	if node is Node2D:
		var script: Script = node.get_script()
		if script != null and script.get_global_name() == &"Player":
			return node as Node2D

	for child in node.get_children():
		var result := _find_first_player_node(child)
		if result != null:
			return result

	return null
