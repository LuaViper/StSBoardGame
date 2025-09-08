class_name Bone

# Member variables.
var data			  # BoneData instance.
var skeleton		  # Skeleton instance.
var parent			# Parent Bone instance (if any).
var children = []	 # Array to hold child Bones.
var x = 0.0
var y = 0.0
var rotation = 0.0
var scale_x = 1.0
var scale_y = 1.0
var shear_x = 0.0
var shear_y = 0.0
var applied_rotation = 0.0
var a = 0.0
var b = 0.0
var world_x = 0.0
var c = 0.0
var d = 0.0
var world_y = 0.0
var world_sign_x = 1.0
var world_sign_y = 1.0
var sorted = false

# Constructor
func _init(data, skeleton, parent = null):
	if data == null:
		push_error("data cannot be null.")
		return
	if skeleton == null:
		push_error("skeleton cannot be null.")
		return
	self.data = data
	self.skeleton = skeleton
	self.parent = parent
	set_to_setup_pose()

# Updates the bone's world transform using current local values.
func update():
	update_world_transform(x, y, rotation, scale_x, scale_y, shear_x, shear_y)

func update_world_transform_0args():
	update_world_transform(x, y, rotation, scale_x, scale_y, shear_x, shear_y)
	
# Updates the bone's world transform with specific values.
func update_world_transform(px, py, protation, pscale_x, pscale_y, pshear_x, pshear_y):
	applied_rotation = protation
	var rotation_y = protation + 90.0 + pshear_y
	var la = cos(deg_to_rad(protation + pshear_x)) * pscale_x
	var lb = cos(deg_to_rad(rotation_y)) * pscale_y
	var lc = sin(deg_to_rad(protation + pshear_x)) * pscale_x
	var ld = sin(deg_to_rad(rotation_y)) * pscale_y

	if parent == null:
		if skeleton.flip_x:
			px = -px
			la = -la
			lb = -lb
		if skeleton.flip_y:
			py = -py
			lc = -lc
			ld = -ld

		a = la
		b = lb
		c = lc
		d = ld
		world_x = px
		world_y = py
		world_sign_x = sign(pscale_x)
		world_sign_y = sign(pscale_y)
	else:
		var pa = parent.a
		var pb = parent.b
		var pc = parent.c
		var pd = parent.d
		world_x = pa * px + pb * py + parent.world_x
		world_y = pc * px + pd * py + parent.world_y
		world_sign_x = parent.world_sign_x * sign(pscale_x)
		world_sign_y = parent.world_sign_y * sign(pscale_y)

		if data.inherit_rotation and data.inherit_scale:
			a = pa * la + pb * lc
			b = pa * lb + pb * ld
			c = pc * la + pd * lc
			d = pc * lb + pd * ld
		else:
			if data.inherit_rotation:
				#TODO: Copilot completely gave up on this section
				pa = 1.0
				pb = 0.0
				pc = 0.0
				pd = 1.0
				var var43:float
				while(true):
					var cos_value:float=cos(deg_to_rad(parent.applied_rotation))
					var sin_value:float=cos(deg_to_rad(parent.applied_rotation))
					var temp:float = pa * cos_value + pb * sin_value
					pb = pb * cos_value - pa * sin_value
					pa = temp
					var43 = pc * cos_value + pd * sin_value
					pd = pd * cos_value - pc * sin_value
					pc = var43
					if(!parent.data.inherit_rotation):
						break		
					parent=parent.parent
					if(parent==null):
						break
				a = pa * la + pb * lc
				b = pa * lb + pb * ld
				c = var43 * la + pd * lc
				d = var43 * lb + pd * ld
			elif not data.inherit_scale:
				a = la
				b = lb
				c = lc
				d = ld
			else:
				pa = 1.0
				pb = 0.0
				pc = 0.0
				pd = 1.0
				var temp:float
				while(true):
					var cos_value:float=cos(deg_to_rad(parent.applied_rotation))
					var sin_value:float=cos(deg_to_rad(parent.applied_rotation))
					var psx:float = parent.scale_x
					var psy:float = parent.scale_y
					var za:float = cos_value * psx
					var zb:float = sin_value * psy
					var zc:float = sin_value * psx
					var zd:float = cos_value * psy
					temp = pa * za + pb * zc
					pb = pb * zd - pa * zb
					pa = temp
					temp = pc * za + pd * zc
					pd = pd * zd - pc * zb
					pc = temp
					if(psx >= 0.0):
						sin_value = -sin_value
					var var45:float = pa * cos_value + pb * sin_value
					pb = pb * cos_value - pa * sin_value
					pa = var45
					temp = pc * cos_value + pd * sin_value
					pd = pd * cos_value - pc * sin_value
					pc = temp
					if(!parent.data.inheritScale):
						break
					parent=parent.parent
					if(parent==null):
						break
				a = pa * la + pb * lc
				b = pa * lb + pb * ld
				c = temp * la + pd * lc
				d = temp * lb + pd * ld				

			if skeleton.flip_x:
				a = -a
				b = -b
			if skeleton.flip_y:
				c = -c
				d = -d

# Resets this bone's position, rotation, etc., to the setup pose.
func set_to_setup_pose():
	x = data.x
	y = data.y
	rotation = data.rotation
	scale_x = data.scale_x
	scale_y = data.scale_y
	shear_x = data.shear_x
	shear_y = data.shear_y

# Accessor methods.
func get_data():
	return data

func get_skeleton():
	return skeleton

func get_parent():
	return parent

func get_children():
	return children

func get_x():
	return x

func set_x(value):
	x = value

func get_y():
	return y

func set_y(value):
	y = value

func set_position(px, py):
	x = px
	y = py

func get_rotation():
	return rotation

func set_rotation(value):
	rotation = value

func get_scale_x():
	return scale_x

func set_scale_x(value):
	scale_x = value

func get_scale_y():
	return scale_y

func set_scale_y(value):
	scale_y = value

func set_scale(pscale_x, pscale_y):
	scale_x = pscale_x
	scale_y = pscale_y

func get_shear_x():
	return shear_x

func set_shear_x(value):
	shear_x = value

func get_shear_y():
	return shear_y

func set_shear_y(value):
	shear_y = value

func get_a():
	return a

func get_b():
	return b

func get_c():
	return c

func get_d():
	return d

func get_world_x():
	return world_x

func get_world_y():
	return world_y

func get_world_sign_x():
	return world_sign_x

func get_world_sign_y():
	return world_sign_y

func get_world_rotation_x():
	return atan2(c, a) * (180.0 / PI)

func get_world_rotation_y():
	return atan2(d, b) * (180.0 / PI)

func get_world_scale_x():
	return sqrt(a * a + b * b) * world_sign_x

func get_world_scale_y():
	return sqrt(c * c + d * d) * world_sign_y

# Calculates local rotation X relative to the world.
func world_to_local_rotation_x():
	if parent == null:
		return rotation
	var pa = parent.a
	var pb = parent.b
	var pc = parent.c
	var pd = parent.d
	return atan2(pa * c - pc * a, pd * a - pb * c) * (180.0 / PI)

# Calculates local rotation Y relative to the world.
func world_to_local_rotation_y():
	if parent == null:
		return rotation
	var pa = parent.a
	var pb = parent.b
	var pc = parent.c
	var pd = parent.d
	return atan2(pa * d - pc * b, pd * b - pb * d) * (180.0 / PI)

# Rotates the world transform by the given degrees.
func rotate_world(degrees):
	var cos_value = cos(deg_to_rad(degrees))
	var sin_value = sin(deg_to_rad(degrees))
	var temp_a = a
	var temp_b = b
	var temp_c = c
	var temp_d = d

	a = cos_value * temp_a - sin_value * temp_c
	b = cos_value * temp_b - sin_value * temp_d
	c = sin_value * temp_a + cos_value * temp_c
	d = sin_value * temp_b + cos_value * temp_d

# Updates the local transform values.
func update_local_transform():
	if parent == null:
		x = world_x
		y = world_y
		rotation = atan2(c, a) * (180.0 / PI)
		scale_x = sqrt(a * a + c * c)
		scale_y = sqrt(b * b + d * d)
		shear_x = 0.0
		shear_y = atan2(a * b + c * d, (a * d - b * c)) * (180.0 / PI)
	else:
		var dx = world_x - parent.world_x
		var dy = world_y - parent.world_y
		var pid = 1.0 / (parent.a * parent.d - parent.b * parent.c)

		x = dx * parent.d * pid - dy * parent.b * pid
		y = dy * parent.a * pid - dx * parent.c * pid
		var ia:float = pid * parent.d
		var id:float = pid * parent.a
		var ib:float = pid * parent.b
		var ic:float = pid * parent.c
		
		var ra:float = ia * a - ib * c
		var rb:float = ia * b - ib * d
		var rc:float = id * c - ic * a
		var rd:float = id * d - ic * b
		
		shear_x = 0.0
		scale_x = sqrt(ra * ra + rc * rc)
		if scale_x > 1.0e-4:
			var det = ra * rd - rb * rc
			scale_y = det / scale_x
			shear_y = atan2(ra * rb + rc * rd, det) * (180.0 / PI)
			rotation = atan2(rc, ra) * (180.0 / PI)
		else:
			scale_x = 0.0
			scale_y = sqrt(rb * rb + rd * rd)
			shear_y = 0.0
			rotation = 90.0 - atan2(rd, rb) * (180.0 / PI)
		applied_rotation = rotation

# Gets the world transform matrix.
func get_world_transform(world_transform):
	if world_transform == null:
		push_error("world_transform cannot be null.")
		return
	var val:Array = world_transform.val
	val[0] = a
	val[3] = b
	val[1] = c
	val[4] = d
	val[6] = world_x
	val[7] = world_y
	val[2] = 0.0
	val[5] = 0.0
	val[8] = 1.0
	return world_transform

# Converts world coordinates to local coordinates.
func world_to_local(world):
	var inv_det = 1.0 / (a * d - b * c)
	var x = world.x - world_x
	var y = world.y - world_y
	world.x = x * d * inv_det - y * b * inv_det
	world.y = y * a * inv_det - x * c * inv_det
	return world

# Converts local coordinates to world coordinates.
func local_to_world(local):
	var x = local.x
	var y = local.y
	local.x = x * a + y * b + world_x
	local.y = x * c + y * d + world_y
	return local

# Returns the string representation of this bone.
func _to_string():
	return data.name
