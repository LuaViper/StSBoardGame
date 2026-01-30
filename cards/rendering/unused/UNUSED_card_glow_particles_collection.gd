#class_name CardGlowParticlesCollection
extends Node3D
#
## Attack_Blue is setup in the editor; the others are duplicated during initial setup.
#var attack_blue:GPUParticles3D
#var attack_gold:GPUParticles3D
#var attack_green:GPUParticles3D
#var skill_blue:GPUParticles3D
#var skill_gold:GPUParticles3D
#var skill_green:GPUParticles3D
#var power_blue:GPUParticles3D
#var power_gold:GPUParticles3D
#var power_green:GPUParticles3D
#
#func _ready():
	#attack_blue = %AttackBlue
	#attack_gold = copy_attackblue_and_addchild()	
	#attack_gold.position=Vector3(1,0,0)
	#attack_green = copy_attackblue_and_addchild()	
	#attack_green.position=Vector3(2,0,0)
	#skill_blue = copy_attackblue_and_addchild()	
	#skill_blue.position=Vector3(0,0,1.25)
	#skill_gold = copy_attackblue_and_addchild()	
	#skill_gold.position=Vector3(1,0,1.25)
	#skill_green = copy_attackblue_and_addchild()	
	#skill_green.position=Vector3(2,0,1.25)
	#power_blue = copy_attackblue_and_addchild()	
	#power_blue.position=Vector3(0,0,2.5)
	#power_gold = copy_attackblue_and_addchild()	
	#power_gold.position=Vector3(1,0,2.5)
	#power_green = copy_attackblue_and_addchild()	
	#power_green.position=Vector3(2,0,2.5)
#
#
#static var glow_texture_attack:Texture2D
#static var glow_texture_skill:Texture2D
#static var glow_texture_power:Texture2D
#static var gradient_tex_blue:GradientTexture1D
#static var gradient_tex_gold:GradientTexture1D
#static var gradient_tex_green:GradientTexture1D
#
#static func set_particle_appearance(temp_collection):
	## Run only once, during initial setup.
	## Function is directly modifying temp_collection's emitters, which modifies all particle emitters in common with them.
	#gradient_tex_blue = quick_gradient_tex(Card2D.BLUE_BORDER_GLOW_COLOR)
	#gradient_tex_gold = quick_gradient_tex(Card2D.GOLD_BORDER_GLOW_COLOR)
	#gradient_tex_green = quick_gradient_tex(Card2D.GREEN_BORDER_GLOW_COLOR)
	#
	#var image:Image = Image.create(421, 421, false, Image.FORMAT_RGBA8)
	#AtlasHelper.CARDUI.draw_to_image_centered("512/bg_attack_silhouette",image,Vector2(421/2.0,421/2.0))
	#glow_texture_attack = ImageTexture.create_from_image(image)
	#image = Image.create(421, 421, false, Image.FORMAT_RGBA8)
	#AtlasHelper.CARDUI.draw_to_image_centered("512/bg_skill_silhouette",image,Vector2(421/2.0,421/2.0))
	#glow_texture_skill = ImageTexture.create_from_image(image)
	#image = Image.create(421, 421, false, Image.FORMAT_RGBA8)
	#AtlasHelper.CARDUI.draw_to_image_centered("512/bg_power_silhouette",image,Vector2(421/2.0,421/2.0))
	#glow_texture_power = ImageTexture.create_from_image(image)
		#
	#set_particles(temp_collection.attack_blue,glow_texture_attack,gradient_tex_blue)
	#set_particles(temp_collection.attack_gold,glow_texture_attack,gradient_tex_gold)
	#set_particles(temp_collection.attack_green,glow_texture_attack,gradient_tex_green)
	#set_particles(temp_collection.skill_blue,glow_texture_skill,gradient_tex_blue)
	#set_particles(temp_collection.skill_gold,glow_texture_skill,gradient_tex_gold)
	#set_particles(temp_collection.skill_green,glow_texture_skill,gradient_tex_green)
	#set_particles(temp_collection.power_blue,glow_texture_power,gradient_tex_blue)
	#set_particles(temp_collection.power_gold,glow_texture_power,gradient_tex_gold)
	#set_particles(temp_collection.power_green,glow_texture_power,gradient_tex_green)	
#
#static func quick_gradient_tex(color):
	## Solid color.
	#var gradient=Gradient.new()
	#gradient.set_offset(0,0)
	#gradient.set_color(0,color)
	## Second point is not optional even for solid color. We checked.
	#gradient.set_offset(1,0)
	#gradient.set_color(1,color)	
	#var tex = GradientTexture1D.new()
	#tex.set_gradient(gradient)
	#return tex
#
#static func set_particles(destination, texture, color_gradient):
	#destination.get_draw_pass_mesh(0).surface_get_material(0).set_texture(BaseMaterial3D.TEXTURE_ALBEDO,texture)
	#destination.get_process_material().set_color_initial_ramp(color_gradient)
#
#func copy_attackblue_and_addchild()->GPUParticles3D:
	#var copy:GPUParticles3D = %AttackBlue.duplicate()
	## Process material must be unique to support different colors
	#copy.set_process_material(copy.get_process_material().duplicate_deep())
	## Draw pass mesh must be unique to support attack/skill/power cards
	#copy.set_draw_pass_mesh(0,copy.get_draw_pass_mesh(0).duplicate_deep())
	#add_child(copy)
	#return copy
	#
## Notes:
	## Process Material:
		## Accelerations > Gravity = 0
		## Display > Scale = Scale Curve > Min Value 0.9948, Max Value 1.11, Presets Ease Out
		## Display > Color Curves > Alpha Curve > CurveTexture > Presets Linear > P1 y 0.6, P2 y 0.0
#
#
## Process Material AND Draw Pass are unique to all 9 emitters but properties are identical
	## (AFTER duplicating GPUParticles3D:
	##	use Make Unique in Process Material dropdown
	##	use Make Unique RECURSIVE in Draw Pass dropdown)
