class_name Event

var data: EventData
var int_value: int = 0
var float_value: float = 0
var string_value: String = ""
var time: float

func _init(_time: float, _data: EventData) -> void:
	if _data == null:
		push_error("data cannot be null.")
	else:
		time = _time
		data = _data

func get_int() -> int:
	return int_value

func set_int(_int_value: int) -> void:
	int_value = _int_value

func get_float() -> float:
	return float_value

func set_float(_float_value: float) -> void:
	float_value = _float_value

func get_string() -> String:
	return string_value

func set_string(_string_value: String) -> void:
	string_value = _string_value

func get_time() -> float:
	return time

func get_data() -> EventData:
	return data

func _to_string() :
	return data.name
