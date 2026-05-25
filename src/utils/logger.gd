class_name GameLogger
extends Node
enum LogLevel {
	DEBUG,
	INFO,
	WARN,
	ERROR,
}

const LEVEL_COLORS: Dictionary = {
	LogLevel.DEBUG: "[color=gray]",
	LogLevel.INFO:  "[color=cyan]",
	LogLevel.WARN:  "[color=yellow]",
	LogLevel.ERROR: "[color=red]",
}

static var min_level: LogLevel = LogLevel.DEBUG
static var enabled: bool = true

static func debug(system: String, message: String) -> void:
	_log(LogLevel.DEBUG, system, message)

static func info(system: String, message: String) -> void:
	_log(LogLevel.INFO, system, message)

static func warn(system: String, message: String) -> void:
	_log(LogLevel.WARN, system, message)

static func error(system: String, message: String) -> void:
	_log(LogLevel.ERROR, system, message)
	push_error("[%s] %s" % [system, message])

static func _log(level: LogLevel, system: String, message: String) -> void:
	if not enabled or level < min_level:
		return
	var level_name: String = LogLevel.keys()[level]
	var timestamp: String = _get_timestamp()
	print("[%s][%s][%s] %s" % [timestamp, level_name, system, message])

static func _get_timestamp() -> String:
	var t: Dictionary = Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [t.hour, t.minute, t.second]
