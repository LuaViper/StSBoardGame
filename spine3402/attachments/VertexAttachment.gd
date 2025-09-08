extends Attachment
class_name VertexAttachment 

#original Java declares bones and vertices as null arrays.  that doesn't work in GDScript
var bones = null
var vertices = null
var world_vertices_length: int

func _init(name):
	super._init(name)

func compute_world_vertices(slot:Slot, world_vertices: Array) -> void:
	compute_world_vertices_extended(slot, 0, world_vertices_length, world_vertices, 0)

func compute_world_vertices_extended(slot:Slot, start: int, count: int, world_vertices: Array, offset: int) -> void:
	count += offset
	var skeleton:Skeleton = slot.get_skeleton()
	var x:float = skeleton.get_x()
	var y:float = skeleton.get_y()
	#TODO: FloatArray
	var deform_array = slot.get_attachment_vertices()
	
	var local_vertices:Array[float] = vertices
	var local_bones:Array[int] = bones
	
	if local_bones == null:
		if deform_array.size() > 0:
			local_vertices = deform_array.items
		var bone = slot.get_bone()
		x += bone.get_world_x()
		y += bone.get_world_y()
		var a = bone.get_a()
		var b = bone.get_b()
		var c = bone.get_c()
		var d = bone.get_d()
		var v = start
		for w in range(offset, count, 2):
			var vx = local_vertices[v]
			var vy = local_vertices[v + 1]
			world_vertices[w] = vx * a + vy * b + x
			world_vertices[w + 1] = vx * c + vy * d + y
			v += 2
	else:
		var v = 0
		var skip = 0

		for i in range(0, start, 2):
			var n = local_bones[v]
			v += n + 1
			skip += n

		var skeleton_bones:Array = skeleton.get_bones()
		if deform_array.size() == 0:
			var w:int = offset
			var b_index:int = skip * 3
			while w < count:
				var wx:float = x
				var wy:float = y
				var n:int = local_bones[v]
				v += 1
				var var42:int = n + v
				while v < var42:
					var bone_index:int = local_bones[v]
					var bone:Bone = skeleton_bones[bone_index]
					var vx:float = local_vertices[b_index]
					var vy:float = local_vertices[b_index + 1]
					var weight:float = local_vertices[b_index + 2]
					wx += (vx * bone.get_a() + vy * bone.get_b() + bone.get_world_x()) * weight
					wy += (vx * bone.get_c() + vy * bone.get_d() + bone.get_world_y()) * weight
					v += 1
					b_index += 3
				world_vertices[w] = wx
				world_vertices[w + 1] = wy
				w += 2
		# Case with deformation.
		else:
			var deform:Array[float] = deform_array.items
			var w:int = offset
			var b_index:int = skip * 3
			var f:int = skip << 1
			while w < count:
				var wx:float = x
				var wy:float = y
				var n:int = local_bones[v]
				v += 1
				var var48:int = n + v		
				while v < var48:
					var bone_index = local_bones[v]
					var bone = skeleton_bones[bone_index]
					var vx = local_vertices[b_index] + deform[f]
					var vy = local_vertices[b_index + 1] + deform[f + 1]
					var weight = local_vertices[b_index + 2]
					wx += (vx * bone.get_a() + vy * bone.get_b() + bone.get_world_x()) * weight
					wy += (vx * bone.get_c() + vy * bone.get_d() + bone.get_world_y()) * weight
					v += 1
					b_index += 3
					f += 2
				world_vertices[w] = wx
				world_vertices[w + 1] = wy
				w += 2
	return

func apply_deform(source_attachment) -> bool:
	return self == source_attachment

func get_bones():
	return bones

func set_bones(new_bones: Array[int]) -> void:
	bones = new_bones

func get_vertices():
	return vertices

func set_vertices(new_vertices: Array) -> void:
	vertices = new_vertices

func get_world_vertices_length() -> int:
	return world_vertices_length

func set_world_vertices_length(length: int) -> void:
	world_vertices_length = length
