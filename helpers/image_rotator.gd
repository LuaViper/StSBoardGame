class_name ImageRotator
extends SubViewport

static var rotator_class = preload("res://helpers/image_rotator.tscn")

static func rotate(image,radians):
	var irc = Globals.main.get_node("%ImageRotatorContainer")
	var rotator = rotator_class.instantiate()
	irc.add_child(rotator)
	var result = await rotator.setup(image, radians)
	rotator.queue_free()
	return result

func setup(image,radians):
	var image_size = image.get_size()
	var image_wid = image_size.x
	var image_hgt = image_size.y
	var new_wid = image_wid*abs(cos(radians)) + image_hgt*abs(sin(radians))
	var new_hgt = image_hgt*abs(cos(radians)) + image_hgt*abs(sin(radians))
	self.size = Vector2(new_wid,new_hgt)
	
	var tex:ImageTexture = ImageTexture.create_from_image(image)
	%Sprite2D.texture = tex
	%Sprite2D.rotation = radians
	%Sprite2D.position = Vector2(new_wid/2,new_hgt/2)
	%Sprite2D.queue_redraw()
	await RenderingServer.frame_post_draw
	var texture = self.get_texture()
	var rotated_image = texture.get_image()
		
	return rotated_image
	

func _ready():
	pass
