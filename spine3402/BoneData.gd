class_name BoneData


var index: int
var name: String
var parent: BoneData
var length: float = 0
var x: float = 0
var y: float = 0
var rotation: float = 0
var scale_x: float = 1.0
var scale_y: float = 1.0
var shear_x: float = 0
var shear_y: float = 0
var inherit_rotation: bool = true
var inherit_scale: bool = true
var color: Color = Color(0.61, 0.61, 0.61, 1.0)

func _init(_index: int, _name: String, _parent: BoneData) -> void:
	if _index < 0:
		push_error("index must be >= 0.")
	elif _name == null:
		push_error("name cannot be null.")
	else:
		index = _index
		name = _name
		parent = _parent

func clone(bone: BoneData, _parent: BoneData) -> void:
	if bone == null:
		push_error("bone cannot be null")
	else:
		index = bone.index
		name = bone.name
		parent = _parent
		length = bone.length
		x = bone.x
		y = bone.y
		rotation = bone.rotation
		scale_x = bone.scale_x
		scale_y = bone.scale_y
		shear_x = bone.shear_x
		shear_y = bone.shear_y

func get_index() -> int:
	return index

func get_name() -> String:
	return name

func get_parent() -> BoneData:
	return parent

func get_length() -> float:
	return length

func set_length(_length: float) -> void:
	length = _length

func get_x() -> float:
	return x

func set_x(_x: float) -> void:
	x = _x

func get_y() -> float:
	return y

func set_y(_y: float) -> void:
	y = _y

func set_position(_x: float, _y: float) -> void:
	x = _x
	y = _y

func get_rotation() -> float:
	return rotation

func set_rotation(_rotation: float) -> void:
	rotation = _rotation

func get_scale_x() -> float:
	return scale_x

func set_scale_x(_scale_x: float) -> void:
	scale_x = _scale_x

func get_scale_y() -> float:
	return scale_y

func set_scale_y(_scale_y: float) -> void:
	scale_y = _scale_y

func set_scale(_scale_x: float, _scale_y: float) -> void:
	scale_x = _scale_x
	scale_y = _scale_y

func get_shear_x() -> float:
	return shear_x

func set_shear_x(_shear_x: float) -> void:
	shear_x = _shear_x

func get_shear_y() -> float:
	return shear_y

func set_shear_y(_shear_y: float) -> void:
	shear_y = _shear_y

func get_inherit_rotation() -> bool:
	return inherit_rotation

func set_inherit_rotation(_inherit_rotation: bool) -> void:
	inherit_rotation = _inherit_rotation

func get_inherit_scale() -> bool:
	return inherit_scale

func set_inherit_scale(_inherit_scale: bool) -> void:
	inherit_scale = _inherit_scale

func get_color() -> Color:
	return color

func _to_string() :
	return name
