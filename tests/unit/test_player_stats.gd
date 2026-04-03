extends GutTest

var _player_stats: PlayerStats = null


func before_each():
	_player_stats = PlayerStats.new()


func after_each():
	_player_stats.free()


func test_initialization():
	assert_eq(_player_stats.max_health, 100)
	assert_eq(_player_stats.current_health, 100)
	assert_eq(_player_stats.attack, 10)
	assert_eq(_player_stats.defense, 5)


func test_take_damage():
	_player_stats.defense = 0
	_player_stats.take_damage(30)
	assert_eq(_player_stats.current_health, 70)


func test_take_damage_with_defense():
	_player_stats.defense = 10
	_player_stats.take_damage(30)
	assert_eq(_player_stats.current_health, 80)


func test_heal():
	_player_stats.current_health = 50
	_player_stats.heal(30)
	assert_eq(_player_stats.current_health, 80)


func test_heal_caps_at_max():
	_player_stats.current_health = 90
	_player_stats.heal(30)
	assert_eq(_player_stats.current_health, 100)


func test_die_signal():
	var died_triggered := false
	_player_stats.died.connect(func(): died_triggered = true)

	_player_stats.current_health = 1
	_player_stats.take_damage(100)

	assert_true(died_triggered)
