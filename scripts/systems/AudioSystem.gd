extends Node

class_name AudioSystem

const SFX_PATH: String = "res://assets/audio/sfx/"

var _sfx_players: Dictionary = {}
var _music_player: AudioStreamPlayer = null
var _master_bus: int = 0
var _sfx_bus: int = 1
var _music_bus: int = 2


func _ready() -> void:
	_setup_audio_buses()


func _setup_audio_buses() -> void:
	for i in range(AudioServer.bus_count):
		var bus_name: String = AudioServer.get_bus_name(i)
		match bus_name:
			"Master":
				_master_bus = i
			"SFX":
				_sfx_bus = i
			"Music":
				_music_bus = i


func play_sfx(sfx_name: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	var player: AudioStreamPlayer = _get_sfx_player()

	if not ResourceLoader.exists(SFX_PATH + sfx_name + ".ogg"):
		if not ResourceLoader.exists(SFX_PATH + sfx_name + ".wav"):
			push_warning("AudioSystem: SFX not found: " + sfx_name)
			return

	var stream: AudioStream = load(SFX_PATH + sfx_name + ".ogg") if ResourceLoader.exists(SFX_PATH + sfx_name + ".ogg") else load(SFX_PATH + sfx_name + ".wav")
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()


func play_music(music_name: String, volume_db: float = -10.0, fade_in: bool = true) -> void:
	if _music_player == null:
		_music_player = AudioStreamPlayer.new()
		_music_player.bus = "Music"
		add_child(_music_player)

	if not ResourceLoader.exists(SFX_PATH + music_name + ".ogg"):
		if not ResourceLoader.exists(SFX_PATH + music_name + ".wav"):
			push_warning("AudioSystem: Music not found: " + music_name)
			return

	var stream: AudioStream = load(SFX_PATH + music_name + ".ogg") if ResourceLoader.exists(SFX_PATH + music_name + ".ogg") else load(SFX_PATH + music_name + ".wav")
	_music_player.stream = stream
	_music_player.volume_db = volume_db

	if fade_in:
		_music_player.volume_db = -80.0
		_music_player.play()
		_fade_in_music(volume_db, 1.0)
	else:
		_music_player.play()


func stop_music(fade_out: bool = true) -> void:
	if _music_player == null or not _music_player.playing:
		return

	if fade_out:
		_fade_out_music(1.0)
	else:
		_music_player.stop()


func _get_sfx_player() -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = "SFX"
	add_child(player)
	player.finished.connect(func(): _recycle_sfx_player(player))
	_sfx_players[player] = true
	return player


func _recycle_sfx_player(player: AudioStreamPlayer) -> void:
	_sfx_players.erase(player)
	player.queue_free()


func _fade_in_music(target_volume: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", target_volume, duration)


func _fade_out_music(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", -80.0, duration)
	tween.tween_callback(_music_player.stop)
