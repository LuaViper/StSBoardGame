class_name TextRenderingViewport
extends SubViewportContainer

const SELF_SCENE = preload("res://text_rendering_viewport.tscn")

@onready var viewport = %SubViewport
@onready var label = %RichTextLabel
var text
var card
var font
var pos
var framecount=0


static func create(text,card,font,pos):
	var o = SELF_SCENE.instantiate()
	o.text=text
	o.card=card
	o.font=font
	o.pos=pos
	return o
	
func _ready():
	label.clear()
	#label.push_font(load("res://Kreon-Regular.ttf"))
	label.push_font(font)
	label.append_text(text)
	label.pop_all()
	label.set("theme_override_constants/line_separation", -10)
	#label.push_font(font)
	
	#label.add_theme_font_override("font", font)
	#label.add_theme_font_size_override("font_size", 32)


func _process(_delta):
	framecount+=1
	if(framecount==2):
		var mesh_instance_node = card.get_node("%Card3D").get_node("Card")
		var destimage = mesh_instance_node.get_surface_override_material(1).get_texture(0).get_image()
		var viewimage = viewport.get_texture().get_image()	
		destimage.blend_rect(viewimage,Rect2i(0,0,1024,1024),Vector2i(pos.x-512,pos.y-512))
		#destimage.save_png("user://test2.png")
		var texture = ImageTexture.new()
		texture.set_image(destimage)		
		var material = StandardMaterial3D.new()
		material.set_transparency(2) #TRANSPARENCY_ALPHA_SCISSOR
		material.albedo_texture = texture		
		mesh_instance_node.set_surface_override_material(1,material)
		self.queue_free()
		
