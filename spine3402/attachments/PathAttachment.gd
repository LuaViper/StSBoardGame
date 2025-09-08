extends VertexAttachment
class_name PathAttachment

var lengths: Array
var closed: bool
var constant_speed: bool
var color = Color(1.0, 0.5, 0.0, 1.0)

func _init(name: String) -> void:
	super._init(name)

func compute_world_vertices(slot, world_vertices: Array) -> void:
	super.compute_world_vertices(slot, world_vertices)

func compute_world_vertices_5args(slot, start: int, count: int, world_vertices: Array, offset: int) -> void:
	super.compute_world_vertices_extended(slot, start, count, world_vertices, offset);

func get_closed() -> bool:
	return closed

func set_closed(value: bool) -> void:
	closed = value

func get_constant_speed() -> bool:
	return constant_speed

func set_constant_speed(value: bool) -> void:
	constant_speed = value

func get_lengths() -> Array:
	return lengths

func set_lengths(value: Array) -> void:
	lengths = value

func get_color() -> Color:
	return color
