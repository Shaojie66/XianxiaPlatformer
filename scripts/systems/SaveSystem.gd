extends Node

class_name SaveSystem

const SAVE_PATH: String = "user://save_game.dat"
const PLAYER_STATS_KEY: String = "player_stats"
const CURRENT_LEVEL_KEY: String = "current_level"
const UNLOCKED_ABILITIES_KEY: String = "unlocked_abilities"
const CURRENT_REALM_KEY: String = "current_realm"

var _save_file: FileAccess = null


func save_game(player_stats: PlayerStats, current_level: String) -> bool:
	_save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if _save_file == null:
		push_error("SaveSystem: Failed to open file for writing: %s" % SAVE_PATH)
		return false

	var save_data: Dictionary = {
		PLAYER_STATS_KEY: _serialize_player_stats(player_stats),
		CURRENT_LEVEL_KEY: current_level,
	}

	_save_file.store_line(JSON.stringify(save_data))
	_save_file.close()
	return true


func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		push_warning("SaveSystem: No save file found")
		return {}

	_save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if _save_file == null:
		push_error("SaveSystem: Failed to open file for reading: %s" % SAVE_PATH)
		return {}

	var json_string := _save_file.get_line()
	_save_file.close()

	var json := JSON.new()
	if json.parse(json_string) != OK:
		push_error("SaveSystem: Failed to parse save file JSON")
		return {}

	var save_data: Dictionary = json.get_data()
	if typeof(save_data) != TYPE_DICTIONARY:
		push_error("SaveSystem: Save file JSON is not a dictionary")
		return {}

	return save_data


func load_player_stats(save_data: Dictionary) -> PlayerStats:
	var stats_dict: Dictionary = save_data.get(PLAYER_STATS_KEY, {})

	var stats := PlayerStats.new()
	stats.max_health = stats_dict.get("max_health", 100)
	stats.current_health = stats_dict.get("current_health", 100)
	stats.attack = stats_dict.get("attack", 10)
	stats.defense = stats_dict.get("defense", 5)
	stats.current_realm = stats_dict.get("current_realm", "炼气")

	var abilities: Array = stats_dict.get("unlocked_abilities", [])
	for ability in abilities:
		if ability is String:
			stats.unlock_ability(ability)

	return stats


func get_saved_level(save_data: Dictionary) -> String:
	return save_data.get(CURRENT_LEVEL_KEY, "Level1_Lianqi")


func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> bool:
	if not has_save_file():
		return true

	var dir := DirAccess.open("user://")
	if dir == null:
		return false

	return dir.remove(SAVE_PATH) == OK


func _serialize_player_stats(stats: PlayerStats) -> Dictionary:
	return {
		"max_health": stats.max_health,
		"current_health": stats.current_health,
		"attack": stats.attack,
		"defense": stats.defense,
		"element": int(stats.element) if stats.element != null else 0,
		"current_realm": stats.current_realm,
		"unlocked_abilities": Array(stats.unlocked_abilities),
	}
