class_name SpineTextureRegion

var texture: Texture2D
var u: float
var v: float
var u2: float
var v2: float
var region_width: int
var region_height: int

func _init(texture: Texture2D = null, x: int = 0, y: int = 0, width: int = 0, height: int = 0):
	if texture:
		self.texture = texture
		set_region(x, y, width if width else texture.get_width(), height if height else texture.get_height())

func set_region(x: int, y: int, width: int, height: int):
	var inv_tex_width = 1.0 / texture.get_width()
	var inv_tex_height = 1.0 / texture.get_height()
	set_region_coords(x * inv_tex_width, y * inv_tex_height, (x + width) * inv_tex_width, (y + height) * inv_tex_height)
	region_width = abs(width)
	region_height = abs(height)

func set_region_coords(u: float, v: float, u2: float, v2: float):
	var tex_width = texture.get_width()
	var tex_height = texture.get_height()
	region_width = int(abs(u2 - u) * tex_width)
	region_height = int(abs(v2 - v) * tex_height)
	self.u = u
	self.v = v
	self.u2 = u2
	self.v2 = v2

func get_texture() -> Texture2D:
	return texture

func flip(x: bool, y: bool):
	if x:
		var temp = u
		u = u2
		u2 = temp
	if y:
		var temp = v
		v = v2
		v2 = temp
