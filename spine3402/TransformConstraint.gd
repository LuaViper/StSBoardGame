class_name TransformConstraint

var data
var bones = []
var target
var rotate_mix: float
var translate_mix: float
var scale_mix: float
var shear_mix: float
var temp = Vector2()

func _init(_data, skeleton):
	if _data == null:
		push_error("data cannot be null.")
		return
	if skeleton == null:
		push_error("skeleton cannot be null.")
		return
	data = _data
	rotate_mix = data.rotate_mix
	translate_mix = data.translate_mix
	scale_mix = data.scale_mix
	shear_mix = data.shear_mix
	for bone_data in data.bones:
		bones.append(skeleton.find_bone(bone_data.name))
	target = skeleton.find_bone(data.target.name)

func _init_copy(constraint, skeleton):
	if constraint == null:
		push_error("constraint cannot be null.")
		return
	if skeleton == null:
		push_error("skeleton cannot be null.")
		return
	data = constraint.data
	bones = []
	for bone in constraint.bones:
		bones.append(skeleton.bones[bone.data.index])
	target = skeleton.bones[constraint.target.data.index]
	rotate_mix = constraint.rotate_mix
	translate_mix = constraint.translate_mix
	scale_mix = constraint.scale_mix
	shear_mix = constraint.shear_mix

func apply():
	update()

func update():
	var ta = target.a
	var tb = target.b
	var tc = target.c
	var td = target.d
	for bone in bones:
		if rotate_mix > 0.0:
			var a = bone.a
			var b = bone.b
			var c = bone.c
			var d = bone.d
			var r = atan2(tc, ta) - atan2(c, a) + data.offset_rotation * (PI / 180.0)
			if r > PI:
				r -= PI * 2
			elif r < -PI:
				r += PI * 2
			r *= rotate_mix
			var cos_r = cos(r)
			var sin_r = sin(r)
			bone.a = cos_r * a - sin_r * c
			bone.b = cos_r * b - sin_r * d
			bone.c = sin_r * a + cos_r * c
			bone.d = sin_r * b + cos_r * d
		
		if translate_mix > 0.0:
			target.local_to_world(temp.set(data.offset_x, data.offset_y))
			bone.world_x += (temp.x - bone.world_x) * translate_mix
			bone.world_y += (temp.y - bone.world_y) * translate_mix
		
		if scale_mix > 0.0:
			var bs = sqrt(bone.a * bone.a + bone.c * bone.c)
			var ts = sqrt(ta * ta + tc * tc)
			var s = bs if bs > 1e-5 else 0.0
			if s:
				s = (bs + (ts - bs + data.offset_scale_x) * scale_mix) / bs
				bone.a *= s
				bone.c *= s
			bs = sqrt(bone.b * bone.b + bone.d * bone.d)
			ts = sqrt(tb * tb + td * td)
			s = bs if bs > 1e-5 else 0.0
			if s:
				s = (bs + (ts - bs + data.offset_scale_y) * scale_mix) / bs
				bone.b *= s
				bone.d *= s
		
		if shear_mix > 0.0:
			var b = bone.b
			var d = bone.d
			var by = atan2(d, b)
			var r = atan2(td, tb) - atan2(tc, ta) - (by - atan2(bone.c, bone.a))
			if r > PI:
				r -= PI * 2
			elif r < -PI:
				r += PI * 2
			r = by + (r + data.offset_shear_y * (PI / 180.0)) * shear_mix
			var s = sqrt(b * b + d * d)
			bone.b = cos(r) * s
			bone.d = sin(r) * s

func get_bones():
	return bones

func get_target():
	return target

func set_target(_target):
	target = _target

func get_rotate_mix():
	return rotate_mix

func set_rotate_mix(_rotate_mix):
	rotate_mix = _rotate_mix

func get_translate_mix():
	return translate_mix

func set_translate_mix(_translate_mix):
	translate_mix = _translate_mix

func get_scale_mix():
	return scale_mix

func set_scale_mix(_scale_mix):
	scale_mix = _scale_mix

func get_shear_mix():
	return shear_mix

func set_shear_mix(_shear_mix):
	shear_mix = _shear_mix

func get_data():
	return data

func _to_string():
	return data.name
