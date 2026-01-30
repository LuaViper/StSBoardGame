class_name Card3D
extends StaticBody3D

var card2dviewport:Card2DRenderingViewport = null
var transparent_viewport:TransparentEffectsRenderingViewport = null
var card:AbstractCard = null
var card_location = null

static var base_card_texture:Texture2D = preload("res://card_cardtexture.png")
static var card_albedo_texture:Texture2D = null
static var shader:Shader = load("res://cards/rendering/ignore_transparent_shadows.gdshader")


var drag_control:Card3DDragControl
func set_drag_control(_dc):
	drag_control=_dc

var card_tray = null

#TO DO LATER: CardGlowParticlesCollection.set_visible(false) when card is hidden
#TO DO LATER: turn individual particles on/off according to card type and glow type
#	(skill/attack/power are easy to turn off, but different colors require a 1.2-sec delay before hiding)
#TO DO LATER: cards have an additional unique effect when End Turn is hovered

static func initialize_card_texture():
	var src = base_card_texture
	var image = src.get_image()
	
	if(image.is_compressed()):
		image.decompress()	#note that this is a one-way process
	
	#image.fill(Color.BLUE) 
	AtlasHelper.CARDUI.draw_to_image("512/card_back",image,Vector2(0,0),2.0)
		
	card_albedo_texture = ImageTexture.create_from_image(image)
	
	#print("Card texture: ",card_albedo_texture)
	#print("Image dimensions: ",image.get_size())		
	#print("Image format: ",image.get_format())
	#print("Image data: ",image.data)
	
func _init():
	card_tray = Globals.card_tray

func _ready():
	%TransparentEffects.hide()

func attach_2d_card_viewport(viewport:Card2DRenderingViewport):
	var tex:ViewportTexture = viewport.get_texture()
	#var img:Image = tex.get_image()
	#print(img.get_pixel(90,90))
	var mesh_instance_node = %Card3DModel.get_node("Card")

	var material
	#Card front
	material = StandardMaterial3D.new()		
	##never use ALPHA -- cards will overlap in hand to obscure energy cost
	#material.set_transparency(StandardMaterial3D.TRANSPARENCY_ALPHA)
	##TODO: option to choose between SCISSOR and DEPTH_PRE_PASS
	material.set_transparency(StandardMaterial3D.TRANSPARENCY_ALPHA_SCISSOR)
	material.alpha_scissor_threshold = 0.5
	#material.set_transparency(StandardMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS)	
	material.albedo_texture = tex
	mesh_instance_node.set_surface_override_material(1,material)	
	
	#Card back/edge
	material = StandardMaterial3D.new()
	material.set_transparency(StandardMaterial3D.TRANSPARENCY_ALPHA_SCISSOR)
	material.albedo_texture = card_albedo_texture
	mesh_instance_node.set_surface_override_material(0,material)	
	self.card2dviewport = viewport
	self.card = viewport.card
	##
	#%Card3DModel.set_cast_shadows_setting(GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	#mesh_instance_node.set_cast_shadows_setting(GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)	

	
func attach_transparent_effects_viewport(viewport:TransparentEffectsRenderingViewport):		
	assert(self.card,"Call attach_2d_card_viewport first!")
	var tex:ViewportTexture = viewport.get_texture()
	# (destination)
	var mesh_instance_node = %TransparentEffects
	# (source canvas)
	viewport.get_node("%TransparentEffects").card=self.card
	mesh_instance_node.show()
	#if true:return
	var material
	material = StandardMaterial3D.new()		
	material.set_transparency(StandardMaterial3D.TRANSPARENCY_ALPHA)
	material.albedo_texture = tex
	mesh_instance_node.set_surface_override_material(0,material)
	self.transparent_viewport = viewport
	

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	#only captures mousedown over a single mousepicked card
	if(drag_control):
		if(event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT):
			if(event.pressed):
				#print("Dragging ",self)
				drag_control.dragged=true
				#%CardGlowParticlesCollection.get_node("%CardGlowParticles").set_emitting(true)

func _input(event):	
	#TODO: dragging should only apply to Card3DDragControl, not all Card3Ds!
	#captures mouseup no matter where it happens
	if(!drag_control): return
	if(drag_control.dragged):
		if(event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and !event.pressed):		
			print("Stop dragging ",self)			
			drag_control.dragged=false
			#%CardGlowParticlesCollection.get_node("%CardGlowParticles").set_emitting(false)
		if(event is InputEventMouseMotion):						
			var tray_collision = get_mouse_intersect(event.position)
			if(tray_collision):
				var local_position = Globals.card_tray.to_local(tray_collision.position)
				if(drag_control):				
					drag_control.position=local_position
					drag_control.position.y=card_tray.get_front_of_tray_for_dragged_card()
					
					
func get_mouse_intersect(mouse_position):
	var camera = get_viewport().get_camera_3d()
	var params = PhysicsRayQueryParameters3D.new()
	params.collision_mask = 0b0010   #layer 2
	params.from = camera.project_ray_origin(mouse_position)
	params.to = camera.project_position(mouse_position,10.0)
	var world_space = get_world_3d().direct_space_state
	var result = world_space.intersect_ray(params)
	return result	

func _on_mouse_entered() -> void:
	#print("?")	
	if(drag_control):drag_control.hovered=true
	pass

func _on_mouse_exited() -> void:
	#TODO: does this trigger as desired on cards that move out from under a stationary cursor?
	#print("!")
	if(drag_control):drag_control.hovered=false
	pass

func _process(delta):
	if(!card): return
	if(card.location == Globals.test_player.hand):
		if(!drag_control):
			self.card_tray=Globals.card_tray
			set_drag_control(card_tray.create_drag_control())
	if(transparent_viewport):
		if(true or card.is_glowing):
			card.glow_timer-=delta
			if(card.glow_timer<=0):
				card.glow_list.append(CardGlowBorder.new(card.glow_color))
				card.glow_timer=max(card.glow_timer+0.3,0)
		for i in range(card.glow_list.size()-1,-1,-1):
			var border=card.glow_list.get(i)
			border.update(delta)
			if(border.is_done):
				card.glow_list.remove_at(i)
		transparent_viewport.get_node("%TransparentEffects").queue_redraw()	

func _physics_process(_delta):
	if(!card): return
	if(card_location != card.location):
		card_location = card.location
		reparent(Globals.main,true)
	if(card.location == Globals.test_player.hand):
		if(drag_control):
			var lerp_speed=0.03
			if(drag_control.hovered): lerp_speed=0.1
			if(drag_control.dragged): lerp_speed=1.0
			#TO DO LATER: immediately snap card to local y when picked up or let go
			transform = transform.interpolate_with(drag_control.global_transform,lerp_speed)
