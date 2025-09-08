class_name PathConstraint

const NONE = -1
const BEFORE = -2
const AFTER = -3

var data: PathConstraintData
var bones: Array = []
var target: Slot
var position: float = 0.0
var spacing: float = 0.0
var rotate_mix: float = 0.0
var translate_mix: float = 0.0
var spaces: Array = []
var positions: Array = []
var world: Array = []
var curves: Array = []
var lengths: Array = []
var segments: Array = []

func _init(var1, _skeleton: Skeleton) -> void:
	assert(var1 is PathConstraintData or var1 is PathConstraint,
		"PathConstraint constructor was called with invalid type for arg1 "+var1.to_string())
	if(var1 is PathConstraintData):
		for i in range(0,10):
			segments.append(0.0)

		if var1 == null:
			push_error("data cannot be null")
		elif _skeleton == null:
			push_error("skeleton cannot be null")
		else:
			data = var1
			bones = []
			for bone_data in var1.bones:
				bones.append(_skeleton.find_bone(bone_data.name))
			target = _skeleton.find_slot(data.target.name)
			position = data.position
			spacing = data.spacing
			rotate_mix = data.rotate_mix
			translate_mix = data.translate_mix
	elif(var1 is PathConstraint):
		if var1 == null:
			push_error("constraint cannot be null")
		elif _skeleton == null:
			push_error("skeleton cannot be null")
		else:
			var constraint = var1
			data = constraint.data
			bones = []
			for bone in var1.bones:
				bones.append(_skeleton.find_bone(bone.data.index))
			target = _skeleton.find_slot(var1.target.data.index)
			position = var1.position
			spacing = var1.spacing
			rotate_mix = var1.rotate_mix
			translate_mix = var1.translate_mix
		

func apply() -> void:
	update()

func update() -> void:
	#TODO: Copilot gave up here and we're not confident in our own interpretation
	var attachment = target.attachment
	if attachment is PathAttachment:
		var rotate_mix_val = rotate_mix
		var translate_mix_val = translate_mix
		var translate = translate_mix_val > 0.0
		var rotate = rotate_mix_val > 0.0
		if translate or rotate:
			var data_ref:PathConstraintData = data
			var spacing_mode = data_ref.spacing_mode
			var length_spacing = spacing_mode == PathConstraintData.SpacingMode.length
			var rotate_mode = data_ref.rotate_mode
			var tangents = rotate_mode == PathConstraintData.RotateMode.tangent
			var scale_val = rotate_mode == PathConstraintData.RotateMode.chain_scale
			var bone_count = bones.size()
			var spaces_count = bone_count if(tangents) else bone_count + 1
			var bones_val:Array = bones
			var spaces_val:Array = spaces
			spaces_val.resize(spaces_count)
			var lengths_val = []
			var spacing_val = spacing
			if(!scale_val && !length_spacing):
				for i in range(0,spaces_count):
					spaces_val[i]=spacing
			else:
				if(scale_val):
					lengths_val = self.lengths.resize(bone_count)
				var i:int = 0
				var length_val:float
				var n:int = spaces_count - 1
				while(i < n):
					var bone_val:Bone = bones_val[i]
					length_val = bone_val.data.length
					var x:float = length_val * bone_val.a
					var y:float = length_val * bone_val.c
					length_val = sqrt(x*x+y*y)
					if(scale_val):
						lengths_val[i] = length_val;
					#TODO: probable decomp jank --
					# in original, it appears i is incremented before spaces is set
					spaces_val[i] = max(0.0,length_val+spacing_val) if(length_spacing) else spacing_val
					i+=1;
					

			var positions:Array = compute_world_positions(attachment, spaces_count, tangents, data_ref.position_mode == PathConstraintData.PositionMode.percent, spacing_mode == PathConstraintData.SpacingMode.percent)
			var skeleton = target.get_skeleton()
			var skeleton_x = skeleton.x
			var skeleton_y = skeleton.y
			var bone_x = positions[0]
			var bone_y = positions[1]
			var offset_rotation = data.offset_rotation
			var tip = rotate_mode == PathConstraintData.RotateMode.chain and offset_rotation == 0.0
			var i = 0

			for p in range(3, bone_count * 3, 3):
				var bone = bones[i]
				bone.world_x += (bone_x - skeleton_x - bone.world_x) * translate_mix
				bone.world_y += (bone_y - skeleton_y - bone.world_y) * translate_mix
				var x = positions[p]
				var y = positions[p + 1]
				var dx = x - bone_x
				var dy = y - bone_y
				
				if(scale_val):
					var length = lengths[i]
					if length != 0.0:
						var s = ((sqrt(dx * dx + dy * dy) / length - 1.0) * rotate_mix) + 1.0
						bone.a *= s
						bone.c *= s

				bone_x = x
				bone_y = y

				if rotate:
					var a = bone.a
					var b = bone.b
					var c = bone.c
					var d = bone.d
					var r
					
					if tangents:
						r = positions[p - 1]
					elif spaces[i + 1] == 0.0:
						r = positions[p + 2]
					else:
						r = atan2(dy, dx)

					r -= atan2(c, a) - offset_rotation * (PI / 180.0)
					
					if tip:
						var cos = cos(r)
						var sin = sin(r)
						var length = bone.data.length
						bone_x = x + (length * (cos * a - sin * c) - dx) * rotate_mix
						bone_y = y + (length * (sin * a + cos * c) - dy) * rotate_mix

					if r > PI:
						r -= (PI * 2.0)
					elif r < -PI:
						r += (PI * 2.0)

					r *= rotate_mix
					var cos_r = cos(r)
					var sin_r = sin(r)
					bone.a = cos_r * a - sin_r * c
					bone.b = cos_r * b - sin_r * d
					bone.c = sin_r * a + cos_r * c
					bone.d = sin_r * b + cos_r * d
				i += 1
				
func compute_world_positions(path: PathAttachment, spaces_count: int, tangents: bool, percent_position: bool, percent_spacing: bool) -> Array:
	var target = self.target
	var position = self.position
	var spaces = self.spaces
	var out_positions = []
	out_positions.resize(spaces_count * 3 + 2)
	var closed = path.get_closed()
	var vertices_length = path.get_world_vertices_length()
	var curve_count = vertices_length / 6
	var prev_curve = -1

	if not path.get_constant_speed():
		var lengths = path.get_lengths()
		curve_count -= 1 if(closed) else 2
		var path_length = lengths[curve_count]

		if percent_position:
			position *= path_length

		if percent_spacing:
			for i in range(spaces_count):
				spaces[i] *= path_length

		var world = []
		world.resize(8)
		var i = 0
		var o = 0

		for curve in range(0, spaces_count):
			#label227
			var space = spaces[i]
			position += space
			var p = position
			if closed:
				p = position % path_length
				if p < 0.0:
					p += path_length

				curve = 0
			else:
				if position < 0.0:
					if prev_curve != -2:
						prev_curve = -2
						path.compute_world_vertices_5args(target, 2, 4, world, 0)

					add_before_position(position, world, 0, out_positions, o)
					#TODO: this was originally break label227. any chance of infinite loop?
					continue

				if position > path_length:
					if prev_curve != -3:
						prev_curve = -3
						path.compute_world_vertices_5args(target, vertices_length - 6, 4, world, 0)

					add_after_position(position - path_length, world, 0, out_positions, o)
					#TODO: this was originally break label227. any chance of infinite loop?
					continue

			while true:
				var length = lengths[curve]
				if p <= length:
					if curve == 0:
						p /= length
					else:
						var prev = lengths[curve - 1]
						p = (p - prev) / (length - prev)

					if curve != prev_curve:
						prev_curve = curve
						if closed and curve == curve_count:
							path.compute_world_vertices_5args(target, vertices_length - 4, 4, world, 0)
							path.compute_world_vertices_5args(target, 0, 4, world, 4)
						else:
							path.compute_world_vertices_5args(target, curve * 6 + 2, 8, world, 0)

					add_curve_position(p, world[0], world[1], world[2], world[3], world[4], world[5], world[6], world[7], out_positions, o, tangents or (i > 0 and space == 0.0))
					break

				curve += 1

			i += 1

		return out_positions
	else:
		var world = []
		if closed:
			vertices_length += 2
			world.resize(vertices_length)
			path.compute_world_vertices_5args(target, 2, vertices_length - 4, world, 0)
			path.compute_world_vertices_5args(target, 0, 2, world, vertices_length - 4)
			world[vertices_length - 2] = world[0]
			world[vertices_length - 1] = world[1]
		else:
			curve_count -= 1
			vertices_length -= 4
			world.resize(vertices_length)
			path.compute_world_vertices_5args(target, 2, vertices_length, world, 0)

			var curves = []
			curves.resize(curve_count)
			var path_length = 0.0
			var x1 = world[0]
			var y1 = world[1]
			var cx1 = 0.0
			var cy1 = 0.0
			var cx2 = 0.0
			var cy2 = 0.0
			var x2 = 0.0
			var y2 = 0.0
			var i = 0

			for w in range(2, curve_count * 6, 6):
				cx1 = world[w]
				cy1 = world[w + 1]
				cx2 = world[w + 2]
				cy2 = world[w + 3]
				x2 = world[w + 4]
				y2 = world[w + 5]
				var tmpx = (x1 - cx1 * 2.0 + cx2) * 0.1875
				var tmpy = (y1 - cy1 * 2.0 + cy2) * 0.1875
				var dddfx = ((cx1 - cx2) * 3.0 - x1 + x2) * 0.09375
				var dddfy = ((cy1 - cy2) * 3.0 - y1 + y2) * 0.09375
				var ddfx = tmpx * 2.0 + dddfx
				var ddfy = tmpy * 2.0 + dddfy
				var dfx = (cx1 - x1) * 0.75 + tmpx + dddfx * 0.16666667
				var dfy = (cy1 - y1) * 0.75 + tmpy + dddfy * 0.16666667
				var curve_start = path_length + sqrt(dfx * dfx + dfy * dfy)
				dfx += ddfx
				dfy += ddfy
				ddfx += dddfx
				ddfy += dddfy
				var curve_middle = curve_start + sqrt(dfx * dfx + dfy * dfy)
				dfx += ddfx
				dfy += ddfy
				var curve_end = curve_middle + sqrt(dfx * dfx + dfy * dfy)
				dfx += ddfx + dddfx
				dfy += ddfy + dddfy
				path_length = curve_end + sqrt(dfx * dfx + dfy * dfy)
				curves[i] = path_length
				x1 = x2
				y1 = y2
				i += 1

			if percent_position:
				position *= path_length

			if percent_spacing:
				for i2 in range(spaces_count):
					spaces[i2] *= path_length

			var curve_length = 0.0
			var i2 = 0
			var o = 0
			var curve = 0
			var segment = 0

	#TODO: may be decompiler jank, but original java declares i a second time here			
			while(i < spaces_count):				
				#label228
				var space = spaces[i2]
				position += space
				var p = position
				if closed:
					p = position % path_length
					if p < 0.0:
						p += path_length
					curve = 0
				else:
					if position < 0.0:
						add_before_position(position, world, 0, out_positions, o)
						continue
					if position > path_length:
						add_after_position(position - path_length, world, vertices_length - 4, out_positions, o)
						continue

				#label189
				while true:
					var length = curves[curve]
					if p <= length:
						if curve == 0:
							p /= length
						else:
							var prev = curves[curve - 1]
							p = (p - prev) / (length - prev)

						if curve != prev_curve:
							prev_curve = curve
							var ii = curve * 6
							x1 = world[ii]
							y1 = world[ii + 1]
							cx1 = world[ii + 2]
							cy1 = world[ii + 3]
							cx2 = world[ii + 4]
							cy2 = world[ii + 5]
							x2 = world[ii + 6]
							y2 = world[ii + 7]

							var tmpx = (x1 - cx1 * 2.0 + cx2) * 0.03
							var tmpy = (y1 - cy1 * 2.0 + cy2) * 0.03
							var dddfx = ((cx1 - cx2) * 3.0 - x1 + x2) * 0.006
							var dddfy = ((cy1 - cy2) * 3.0 - y1 + y2) * 0.006
							var ddfx = tmpx * 2.0 + dddfx
							var ddfy = tmpy * 2.0 + dddfy
							var dfx = (cx1 - x1) * 0.3 + tmpx + dddfx * 0.16666667
							var dfy = (cy1 - y1) * 0.3 + tmpy + dddfy * 0.16666667
							curve_length = sqrt(dfx * dfx + dfy * dfy)
							segments[0] = curve_length

							for var89 in range(1, 8):
								dfx += ddfx
								dfy += ddfy
								ddfx += dddfx
								ddfy += dddfy
								curve_length += sqrt(dfx * dfx + dfy * dfy)
								segments[var89] = curve_length

							dfx += ddfx
							dfy += ddfy
							var var84 = curve_length + sqrt(dfx * dfx + dfy * dfy)
							segments[8] = var84
							dfx += ddfx + dddfx
							dfy += ddfy + dddfy
							curve_length = var84 + sqrt(dfx * dfx + dfy * dfy)
							segments[9] = curve_length

						p *= curve_length

						var break189:bool = false
						while true:
							length = segments[segment]
							if p <= length:
								if segment == 0:
									p /= length
								else:
									var prev = segments[segment - 1]
									p = float(segment) + (p - prev) / (length - prev)

								add_curve_position(p * 0.1, x1, y1, cx1, cy1, cx2, cy2, x2, y2, out_positions, o, tangents or (i > 0 and space == 0.0))
								break189 = true
								break #break label189
							segment += 1
							if(break189):
								break
					curve += 1
				o += 3
				i += 1

		return out_positions

func add_before_position(p: float, temp: Array , i: int, out_positions: Array, o: int) -> void:
	var x1 = temp[i]
	var y1 = temp[i + 1]
	var dx = temp[i + 2] - x1
	var dy = temp[i + 3] - y1
	var r = atan2(dy, dx)
	out_positions[o] = x1 + p * cos(r)
	out_positions[o + 1] = y1 + p * sin(r)
	out_positions[o + 2] = r

func add_after_position(p: float, temp: Array, i: int, out_positions: Array, o: int) -> void:
	var x1 = temp[i + 2]
	var y1 = temp[i + 3]
	var dx = x1 - temp[i]
	var dy = y1 - temp[i + 1]
	var r = atan2(dy, dx)
	out_positions[o] = x1 + p * cos(r)
	out_positions[o + 1] = y1 + p * sin(r)
	out_positions[o + 2] = r

func add_curve_position(p: float, x1: float, y1: float, cx1: float, cy1: float, cx2: float, cy2: float, x2: float, y2: float, out_positions: Array, o: int, tangents: bool) -> void:
	if p == 0.0:
		p = 0.0001

	var tt = p * p
	var ttt = tt * p
	var u = 1.0 - p
	var uu = u * u
	var uuu = uu * u
	var ut = u * p
	var ut3 = ut * 3.0
	var uut3 = u * ut3
	var utt3 = ut3 * p
	var x = x1 * uuu + cx1 * uut3 + cx2 * utt3 + x2 * ttt
	var y = y1 * uuu + cy1 * uut3 + cy2 * utt3 + y2 * ttt
	out_positions[o] = x
	out_positions[o + 1] = y

	if tangents:
		out_positions[o + 2] = atan2(y - (y1 * uu + cy1 * ut * 2.0 + cy2 * tt), x - (x1 * uu + cx1 * ut * 2.0 + cx2 * tt))

func get_position() -> float:
	return position

func set_position(position_val: float) -> void:
	position = position_val

func get_spacing() -> float:
	return spacing

func set_spacing(spacing_val: float) -> void:
	spacing = spacing_val

func get_rotate_mix() -> float:
	return rotate_mix

func set_rotate_mix(rotate_mix_val: float) -> void:
	rotate_mix = rotate_mix_val

func get_translate_mix() -> float:
	return translate_mix

func set_translate_mix(translate_mix_val: float) -> void:
	translate_mix = translate_mix_val

func get_bones() -> Array:
	return bones

func get_target() -> Slot:
	return target

func set_target(target_val: Slot) -> void:
	target = target_val

func get_data() -> PathConstraintData:
	return data

func _to_string() :
	return data.name
