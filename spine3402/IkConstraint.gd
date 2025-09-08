class_name IkConstraint

var data: IkConstraintData
var bones: Array = []
var target: Bone
var mix: float = 1.0
var bend_direction: int = 0
var level: int = 0

func _init(_data: IkConstraintData, _skeleton: Skeleton) -> void:
	if _data == null:
		push_error("data cannot be null.")
	elif _skeleton == null:
		push_error("skeleton cannot be null.")
	else:
		data = _data
		mix = _data.mix
		bend_direction = _data.bend_direction
		bones = []

		for bone_data in _data.bones:
			bones.append(_skeleton.find_bone(bone_data.name))
		
		target = _skeleton.find_bone(_data.target.name)

func clone(constraint: IkConstraint, _skeleton: Skeleton) -> void:
	if constraint == null:
		push_error("constraint cannot be null")
	elif _skeleton == null:
		push_error("skeleton cannot be null")
	else:
		data = constraint.data
		bones = []

		for bone in constraint.bones:
			bones.append(_skeleton.bones[bone.data.index])
		
		target = _skeleton.bones[constraint.target.data.index]
		mix = constraint.mix
		bend_direction = constraint.bend_direction

func apply() -> void:
	update()

func update() -> void:
	var _target = target
	var _bones = bones
	match _bones.size():
		1:
			IkConstraint.apply_4args(_bones[0], _target.world_x, _target.world_y, mix)
		2:
			IkConstraint.apply_6args(_bones[0], _bones[1], _target.world_x, _target.world_y, bend_direction, mix)

func get_bones() -> Array:
	return bones

func get_target() -> Bone:
	return target

func set_target(_target: Bone) -> void:
	target = _target

func get_mix() -> float:
	return mix

func set_mix(_mix: float) -> void:
	mix = _mix

func get_bend_direction() -> int:
	return bend_direction

func set_bend_direction(_bend_direction: int) -> void:
	bend_direction = _bend_direction

func get_data() -> IkConstraintData:
	return data

func _to_string() :
	return data.name

static func apply_4args(bone: Bone, target_x: float, target_y: float, alpha: float) -> void:
	var pp = bone.parent
	var id = 1.0 / (pp.a * pp.d - pp.b * pp.c)
	var x = target_x - pp.world_x
	var y = target_y - pp.world_y
	var tx = (x * pp.d - y * pp.b) * id - bone.x
	var ty = (y * pp.a - x * pp.c) * id - bone.y
	var rotation_ik = atan2(ty, tx) * (180.0 / PI) - bone.shear_x - bone.rotation

	if bone.scale_x < 0.0:
		rotation_ik += 180.0

	if rotation_ik > 180.0:
		rotation_ik -= 360.0
	elif rotation_ik < -180.0:
		rotation_ik += 360.0

	bone.update_world_transform(bone.x, bone.y, bone.rotation + rotation_ik * alpha, bone.scale_x, bone.scale_y, bone.shear_x, bone.shear_y)

static func apply_6args(parent: Bone, child: Bone, target_x: float, target_y: float, bend_dir: int, alpha: float) -> void:
	if alpha == 0.0:
		child.update_world_transform_0args()
	else:
		var px = parent.x
		var py = parent.y
		var psx = parent.scale_x
		var psy = parent.scale_y
		var csx = child.scale_x
		var os1
		var s2

		if psx < 0.0:
			psx = -psx
			os1 = 180
			s2 = -1
		else:
			os1 = 0
			s2 = 1

		if psy < 0.0:
			psy = -psy
			s2 = -s2

		var os2
		if csx < 0.0:
			csx = -csx
			os2 = 180
		else:
			os2 = 0

		var cx = child.x
		var a = parent.a
		var b = parent.b
		var c = parent.c
		var d = parent.d
		var u:bool = abs(psx - psy) <= 0.0001
		var cy = 0.0
		var cwx = 0.0
		var cwy = 0.0

		if not u:
			cy = 0.0
			cwx = a * cx + parent.world_x
			cwy = c * cx + parent.world_y
		else:
			cy = child.y
			cwx = a * cx + b * cy + parent.world_x
			cwy = c * cx + d * cy + parent.world_y

		var pp = parent.parent
		a = pp.a
		b = pp.b
		c = pp.c
		d = pp.d
		var id = 1.0 / (a * d - b * c)
		var x = target_x - pp.world_x
		var y = target_y - pp.world_y
		var tx = (x * d - y * b) * id - px
		var ty = (y * a - x * c) * id - py
		x = cwx - pp.world_x
		y = cwy - pp.world_y
		var dx = (x * d - y * b) * id - px
		var dy = (y * a - x * c) * id - py
		var l1 = sqrt(dx * dx + dy * dy)
		var l2 = child.data.length * csx
		var a1 = 0.0
		var a2 = 0.0

		if u:
			l2 *= psx
			var cos = (tx * tx + ty * ty - l1 * l1 - l2 * l2) / (2.0 * l1 * l2)
			cos = clamp(cos, -1.0, 1.0)
			a2 = acos(cos) * bend_dir
			a = l1 + l2 * cos
			b = l2 * sin(a2)
			a1 = atan2(ty * a - tx * b, tx * a + ty * b)
		else:
			#TODO: Copilot gave up on this section			 
			while(true): #label95:
				a = psx * l2
				b = psy * l2
				var aa:float = a * a
				var bb:float = b * b
				var dd:float = tx * tx + ty * ty
				var ta:float = atan2(ty, tx)
				c = bb * l1 * l1 + aa * dd - aa * bb
				var c1:float = -2.0 * bb * l1
				var c2:float = bb - aa
				d = c1 * c1 - 4.0 * c2 * c
				if(d >= 0.0):
					var q:float = sqrt(d)
					if(c1 < 0.0):
						q = -q
					
					q = -(c1 + q) / 2.0
					var r0:float = q / c2
					var r1:float = c / q
					var r:float = r0 if(abs(r0)<abs(r1)) else r1
					if (r * r <= dd):
						y = sqrt((dd-r*r)*(bend_dir))
						a1 = ta - atan2(y, r)
						a2 = atan2( y / psy, (r - l1) / psx)
						continue	#break label95
				
				var min_angle:float = 0.0
				var min_dist:float = INF #Float.MAX_VALUE
				var min_x:float = 0.0
				var min_y:float = 0.0
				var max_angle:float = 0.0
				var max_dist:float = 0.0
				var max_x:float = 0.0
				var max_y:float = 0.0
				x = l1 + a
				d = x * x
				if(d > max_dist):
					max_angle = 0.0
					max_dist = d
					max_x = x
				
				x = l1 - a
				d = x * x
				if(d < min_dist):
					min_angle = PI
					min_dist = dd
					min_x = x
					
				var angle:float = acos((-a * l1 / (aa - bb)))
				x = a * cos(angle) + l1
				y = b * sin(angle)
				d = x * x + y * y
				if(d < min_dist):
					min_angle = angle
					min_dist = d
					min_x = x
					min_y = y
				
				if(d > max_dist):
					max_angle = angle
					max_dist = d
					max_x = x
					max_y = y
				
				if(dd <= (min_dist + max_dist) / 2.0):
					a1 = ta - atan2(min_y * bend_dir, min_x)
					a2 = min_angle * bend_dir
				else:
					a1 = ta - atan2(max_y * bend_dir, max_x)
					a2 = max_angle * bend_dir

				break
			

		var os = atan2(cy, cx) * s2
		var rotation = parent.rotation
		a1 = (a1 - os) * (180.0 / PI) + os1 - rotation

		if a1 > 180.0:
			a1 -= 360.0
		elif a1 < -180.0:
			a1 += 360.0

		parent.update_world_transform(px, py, rotation + a1 * alpha, parent.scale_x, parent.scale_y, 0.0, 0.0)
		rotation = child.rotation
		a2 = ((a2 + os) * (180.0 / PI) - child.shear_x) * s2 + os2 - rotation

		if a2 > 180.0:
			a2 -= 360.0
		elif a2 < -180.0:
			a2 += 360.0

		child.update_world_transform(cx, cy, rotation + a2 * alpha, child.scale_x, child.scale_y, child.shear_x, child.shear_y)
