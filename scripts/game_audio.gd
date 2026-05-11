extends Node

## Procedural one-shot beeps (no external assets). Respects /root/GameSettings sfx_enabled.

var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)
	if OS.has_feature("web"):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)


func _can_play() -> bool:
	var gs := get_node_or_null("/root/GameSettings")
	return gs != null and bool(gs.get("sfx_enabled"))


func _tone(freq: float, ms: float, vol: float = 0.22) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	var rate := 22050
	var n: int = maxi(1, int(rate * ms / 1000.0))
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var s: float = sin(TAU * freq * float(i) / float(rate)) * vol
		var si: int = int(clampf(s * 32767.0, -32767.0, 32767.0))
		data[i * 2] = si & 0xFF
		data[i * 2 + 1] = (si >> 8) & 0xFF
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	return wav


func play_sensor() -> void:
	if not _can_play():
		return
	_player.stream = _tone(660.0, 55.0, 0.18)
	_player.play()


func play_hazard() -> void:
	if not _can_play():
		return
	_player.stream = _tone(220.0, 90.0, 0.28)
	_player.play()


func play_death() -> void:
	if not _can_play():
		return
	_player.stream = _tone(110.0, 160.0, 0.32)
	_player.play()


func play_exit() -> void:
	if not _can_play():
		return
	_player.stream = _tone(880.0, 120.0, 0.2)
	_player.play()


func unlock_web_audio() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
