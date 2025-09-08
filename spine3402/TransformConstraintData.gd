class_name TransformConstraintData

var name: String
var bones = []
var target
var rotate_mix: float
var translate_mix: float
var scale_mix: float
var shear_mix: float
var offset_rotation: float
var offset_x: float
var offset_y: float
var offset_scale_x: float
var offset_scale_y: float
var offset_shear_y: float

func _init(_name: String):
	if _name == null:
		push_error("name cannot be null.")
		return
	name = _name

func get_name() -> String:
	return name

func get_bones() -> Array:
	return bones

func get_target():
	return target

func set_target(_target):
	if _target == null:
		push_error("target cannot be null.")
		return
	target = _target

func get_rotate_mix() -> float:
	return rotate_mix

func set_rotate_mix(_rotate_mix: float):
	rotate_mix = _rotate_mix

func get_translate_mix() -> float:
	return translate_mix

func set_translate_mix(_translate_mix: float):
	translate_mix = _translate_mix

func get_scale_mix() -> float:
	return scale_mix

func set_scale_mix(_scale_mix: float):
	scale_mix = _scale_mix

func get_shear_mix() -> float:
	return shear_mix

func set_shear_mix(_shear_mix: float):
	shear_mix = _shear_mix

func get_offset_rotation() -> float:
	return offset_rotation

func set_offset_rotation(_offset_rotation: float):
	offset_rotation = _offset_rotation

func get_offset_x() -> float:
	return offset_x

func set_offset_x(_offset_x: float):
	offset_x = _offset_x

func get_offset_y() -> float:
	return offset_y

func set_offset_y(_offset_y: float):
	offset_y = _offset_y

func get_offset_scale_x() -> float:
	return offset_scale_x

func set_offset_scale_x(_offset_scale_x: float):
	offset_scale_x = _offset_scale_x

func get_offset_scale_y() -> float:
	return offset_scale_y

func set_offset_scale_y(_offset_scale_y: float):
	offset_scale_y = _offset_scale_y

func get_offset_shear_y() -> float:
	return offset_shear_y

func set_offset_shear_y(_offset_shear_y: float):
	offset_shear_y = _offset_shear_y

func _to_string() :
	return name
