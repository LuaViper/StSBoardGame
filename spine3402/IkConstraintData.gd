class_name IkConstraintData

var name: String
var bones: Array = []
var target: BoneData
var bend_direction: int = 1
var mix: float = 1.0

func _init(_name: String) -> void:
	if _name == null:
		push_error("name cannot be null.")
	else:
		name = _name

func get_name() -> String:
	return name

func get_bones() -> Array:
	return bones

func get_target() -> BoneData:
	return target

func set_target(_target: BoneData) -> void:
	if _target == null:
		push_error("target cannot be null.")
	else:
		target = _target

func get_bend_direction() -> int:
	return bend_direction

func set_bend_direction(_bend_direction: int) -> void:
	bend_direction = _bend_direction

func get_mix() -> float:
	return mix

func set_mix(_mix: float) -> void:
	mix = _mix

func _to_string() :
	return name
