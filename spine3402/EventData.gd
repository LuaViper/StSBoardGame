class_name EventData

var name: String
var int_value: int = 0
var float_value: float = 0
var string_value: String = ""

func _init(_name: String) -> void:
	if _name == null:
		push_error("name cannot be null.")
	else:
		name = _name

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

func get_name() -> String:
	return name

func _to_string() :
	return name
