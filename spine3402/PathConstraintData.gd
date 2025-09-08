class_name PathConstraintData

# Class properties
var name: String
var bones: Array = []
var target: SlotData
var position_mode: PositionMode
var spacing_mode: SpacingMode
var rotate_mode: RotateMode
var offset_rotation: float = 0.0
var position: float = 0.0
var spacing: float = 0.0
var rotate_mix: float = 0.0
var translate_mix: float = 0.0

# Constructor
func _init(_name: String) -> void:
	if _name == null:
		push_error("name cannot be null.")
	else:
		name = _name

# Getters and setters
func get_bones() -> Array:
	return bones

func get_target() -> SlotData:
	return target

func set_target(_target: SlotData) -> void:
	target = _target

func get_position_mode() -> PositionMode:
	return position_mode

func set_position_mode(_position_mode: PositionMode) -> void:
	position_mode = _position_mode

func get_spacing_mode() -> SpacingMode:
	return spacing_mode

func set_spacing_mode(_spacing_mode: SpacingMode) -> void:
	spacing_mode = _spacing_mode

func get_rotate_mode() -> RotateMode:
	return rotate_mode

func set_rotate_mode(_rotate_mode: RotateMode) -> void:
	rotate_mode = _rotate_mode

func get_offset_rotation() -> float:
	return offset_rotation

func set_offset_rotation(_offset_rotation: float) -> void:
	offset_rotation = _offset_rotation

func get_position() -> float:
	return position

func set_position(_position: float) -> void:
	position = _position

func get_spacing() -> float:
	return spacing

func set_spacing(_spacing: float) -> void:
	spacing = _spacing

func get_rotate_mix() -> float:
	return rotate_mix

func set_rotate_mix(_rotate_mix: float) -> void:
	rotate_mix = _rotate_mix

func get_translate_mix() -> float:
	return translate_mix

func set_translate_mix(_translate_mix: float) -> void:
	translate_mix = _translate_mix

func get_name() -> String:
	return name

func _to_string() :
	return name

# Enums
enum PositionMode { fixed, percent }
enum SpacingMode { length, fixed, percent }
enum RotateMode { tangent, chain, chain_scale }
