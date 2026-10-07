extends Node
## Autoload (global) script. Stores scene paths and the best survival time,
## and saves the best time to disk so it survives restarts.

const SPLASH_SCENE := "res://SPLASH/splash_scene.tscn"
const LOBBY_SCENE := "res://LOBBY/lobby.tscn"
const MAP_SCENE := "res://MAP/map.tscn"
const SAVE_PATH := "user://maze_runner_save.cfg"

var best_time: float = 0.0   # fastest escape in seconds (0 = no record yet)
var last_time: float = 0.0


func _ready() -> void:
	_load()


## Returns true if this escape time is a new record.
func record_win(time_seconds: float) -> bool:
	last_time = time_seconds
	if best_time == 0.0 or time_seconds < best_time:
		best_time = time_seconds
		_save()
		return true
	return false


func format_time(t: float) -> String:
	var minutes := int(t) / 60
	var seconds := fmod(t, 60.0)
	return "%02d:%04.1f" % [minutes, seconds]


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("records", "best_time", best_time)
	cfg.save(SAVE_PATH)


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best_time = cfg.get_value("records", "best_time", 0.0)
