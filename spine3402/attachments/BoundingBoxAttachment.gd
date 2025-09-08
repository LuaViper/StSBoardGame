extends VertexAttachment
class_name BoundingBoxAttachment

const COLOR = Color(0.38, 0.94, 0.0, 1.0)

func _init(name: String):
	super(name)

func compute_world_vertices(slot, world_vertices):
	super.compute_world_vertices(slot, world_vertices)

func get_color() -> Color:
	return COLOR
