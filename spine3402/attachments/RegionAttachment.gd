extends Attachment
class_name RegionAttachment

# Constants defining the vertex indices.
const BLX = 0
const BLY = 1
const ULX = 2
const ULY = 3
const URX = 4
const URY = 5
const BRX = 6
const BRY = 7

# Member variables.
var region:TextureRegion_
var path: String = ""
var x: float = 0.0
var y: float = 0.0
var scale_x: float = 1.0
var scale_y: float = 1.0
var rotation: float = 0.0
var width: float = 0.0
var height: float = 0.0
# Allocate an array of 20 floats for vertices.
var vertices: Array = [
	0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0, 0.0
]
# Allocate an array of 8 floats for the offset.
var offset: Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var color: Color = Color(1.0, 1.0, 1.0, 1.0)

func _init(name: String) -> void:
	# Call the parent Attachment's initializer.
	super._init(name)


# Updates the offset array based on region, scale, rotation, and position.
func update_offset() -> void:
	var width = get_width()
	var height = get_height()
	var local_x2 = width / 2.0
	var local_y2 = height / 2.0
	var local_x = -local_x2
	var local_y = -local_y2
	
	# If the region is an AtlasRegion, adjust by its offsets.
	#if region and region is AtlasRegion:
	#	var r:AtlasRegion = region as AtlasRegion
	if region:
		var r = region
		if r.rotate:
			local_x += r.offset_x / float(r.original_width) * width
			local_y += r.offset_y / float(r.original_height) * height
			local_x2 -= (r.original_width - r.offset_x - float(r.packed_height)) / float(r.original_width) * width
			local_y2 -= (r.original_height - r.offset_y - float(r.packed_width)) / float(r.original_height) * height
		else:
			local_x += r.offset_x / float(r.original_width) * width
			local_y += r.offset_y / float(r.original_height) * height
			local_x2 -= (r.original_width - r.offset_x - float(r.packed_width)) / float(r.original_width) * width
			local_y2 -= (r.original_height - r.offset_y - float(r.packed_height)) / float(r.original_height) * height
	
	var s_x = get_scale_x()
	var s_y = get_scale_y()
	local_x *= s_x
	local_y *= s_y
	local_x2 *= s_x
	local_y2 *= s_y
	
	var rot = get_rotation()
	
	#TODO: original java uses a lookup table function;
	# verify these results are as expected
	var cos_val = cos(deg_to_rad(rot))
	var sin_val = sin(deg_to_rad(rot))
	
	var x_pos = get_x()
	var y_pos = get_y()
	var local_x_cos = local_x * cos_val + x_pos
	var local_x_sin = local_x * sin_val
	var local_y_cos = local_y * cos_val + y_pos
	var local_y_sin = local_y * sin_val
	var local_x2_cos = local_x2 * cos_val + x_pos
	var local_x2_sin = local_x2 * sin_val
	var local_y2_cos = local_y2 * cos_val + y_pos
	var local_y2_sin = local_y2 * sin_val
	
	offset[0] = local_x_cos - local_y_sin
	offset[1] = local_y_cos + local_x_sin
	offset[2] = local_x_cos - local_y2_sin
	offset[3] = local_y2_cos + local_x_sin
	offset[4] = local_x2_cos - local_y2_sin
	offset[5] = local_y2_cos + local_x2_sin
	offset[6] = local_x2_cos - local_y_sin
	offset[7] = local_y_cos + local_x2_sin


# Sets the TextureRegion. Adjusts texture coordinates in the vertices array.
func set_region(region_param) -> void:
	assert(region_param != null,"region cannot be null.")

	region = region_param
	# Adjust texture coordinate vertices based on whether the region is rotated.
	#if region is AtlasRegion and (region as AtlasRegion).rotate:
	if(region and region.rotate):
		vertices[13] = region.u
		vertices[14] = region.v2
		vertices[18] = region.u
		vertices[19] = region.v
		vertices[3]  = region.u2
		vertices[4]  = region.v
		vertices[8]  = region.u2
		vertices[9]  = region.v2
	else:
		vertices[8]  = region.u
		vertices[9]  = region.v2
		vertices[13] = region.u
		vertices[14] = region.v
		vertices[18] = region.u2
		vertices[19] = region.v
		vertices[3]  = region.u2
		vertices[4]  = region.v2
		
		#vertices[13] = region.get("u",0.0)
		#vertices[14] = region.get("v2",0.0)
		#vertices[18] = region.get("u",0.0)
		#vertices[19] = region.get("v",0.0)
		#vertices[3]  = region.get("u2",0.0)
		#vertices[4]  = region.get("v",0.0)
		#vertices[8]  = region.get("u2",0.0)
		#vertices[9]  = region.get("v2",0.0)
	#else:
		#vertices[8]  = region.get("u",0.0)
		#vertices[9]  = region.get("v2",0.0)
		#vertices[13] = region.get("u",0.0)
		#vertices[14] = region.get("v",0.0)
		#vertices[18] = region.get("u2",0.0)
		#vertices[19] = region.get("v",0.0)
		#vertices[3]  = region.get("u2",0.0)
		#vertices[4]  = region.get("v2",0.0)


func get_region():
	assert(region != null, "Region has not been set: " + str(self))
	return region


# Updates world vertices based on the current skeleton and bone information.
# The premultiplied_alpha flag determines how color values are combined.
func update_world_vertices(slot:Slot, premultiplied_alpha: bool) -> Array:
	var skeleton = slot.get_skeleton()
	var skeleton_color = skeleton.get_color()
	var slot_color = slot.get_color()
	var region_color = color
	var alpha_val = skeleton_color.a * slot_color.a * region_color.a * 255.0
	var multiplier = alpha_val if premultiplied_alpha else 255.0	
	#TODO: why do RGB get multiplied by alpha_val too? possible decomp jank?
	#var r_val = int(skeleton_color.r * slot_color.r * region_color.r * multiplier)	
	#var g_val = int(skeleton_color.g * slot_color.g * region_color.g * multiplier)	
	#var b_val = int(skeleton_color.b * slot_color.b * region_color.b * multiplier)
	var r_val = int(skeleton_color.r * slot_color.r * region_color.r * 255)
	var g_val = int(skeleton_color.g * slot_color.g * region_color.g * 255)
	var b_val = int(skeleton_color.b * slot_color.b * region_color.b * 255)
	var a_int = int(alpha_val)
	
	var packed_int = (a_int << 24) | (b_val << 16) | (g_val << 8) | r_val
	var computed_color = NumberUtils._int_to_float_color(packed_int)
	
	var bone = slot.get_bone()
	var x_pos = skeleton.get_x() + bone.get_world_x()
	var y_pos = skeleton.get_y() + bone.get_world_y()
	var a = bone.get_a()
	var b = bone.get_b()
	var c = bone.get_c()
	var d = bone.get_d()
	
	# Compute positions for each vertex using the bone transformation.
	vertices[0]  = offset[6] * a + offset[7] * b + x_pos
	vertices[1]  = offset[6] * c + offset[7] * d + y_pos
	vertices[2]  = computed_color
	
	vertices[5]  = offset[0] * a + offset[1] * b + x_pos
	vertices[6]  = offset[0] * c + offset[1] * d + y_pos
	vertices[7]  = computed_color
	
	vertices[10] = offset[2] * a + offset[3] * b + x_pos
	vertices[11] = offset[2] * c + offset[3] * d + y_pos
	vertices[12] = computed_color
	
	vertices[15] = offset[4] * a + offset[5] * b + x_pos
	vertices[16] = offset[4] * c + offset[5] * d + y_pos
	vertices[17] = computed_color
	
	return vertices


# Returns the array of world vertices.
func get_world_vertices() -> Array:
	return vertices


# Returns the offset array.
func get_offset() -> Array:
	return offset


# Getter and setter methods:

func get_x() -> float:
	return x

func set_x(value: float) -> void:
	x = value

func get_y() -> float:
	return y

func set_y(value: float) -> void:
	y = value

func get_scale_x() -> float:
	return scale_x

func set_scale_x(value: float) -> void:
	scale_x = value

func get_scale_y() -> float:
	return scale_y

func set_scale_y(value: float) -> void:
	scale_y = value

func get_rotation() -> float:
	return rotation

func set_rotation(value: float) -> void:
	rotation = value

func get_width() -> float:
	return width

func set_width(value: float) -> void:
	width = value

func get_height() -> float:
	return height

func set_height(value: float) -> void:
	height = value

func get_color() -> Color:
	return color

func set_color(value:Color) -> void:
	color = value

func get_path() -> String:
	return path

func set_path(value: String) -> void:
	path = value
