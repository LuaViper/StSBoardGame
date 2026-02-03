class_name Main
extends Node3D

func _on_hash_test_button_pressed() -> void:
	var path:String = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\SlayTheSpire\\desktop-1.0.jar"
	Globals.JarManager.load(path)
	
	var card_library = CardLibrary.new()
	
	
	#print(json)
	
	#thread = Thread.new()
	## You can bind multiple arguments to a function Callable.
	#
	#
#
#
#var thread: Thread
#
#
## Run here and exit.
## The argument is the bound data passed from start().
#func _thread_function(path):
#
	#const TARGET_SHA256_HASH:String = "cfad868ac8d65a88e71a0bf096fb09f78811e553effe0787c5309a655e081673"
	#const CHUNK_SIZE = 1024
#
	#if not FileAccess.file_exists(path):
		#print("File does not exist: ",path)
		#return
	## Start an SHA-256 context.
	#var ctx = HashingContext.new()
	#ctx.start(HashingContext.HASH_SHA256)
	## Open the file to hash.
	#var file = FileAccess.open(path, FileAccess.READ)
	## Update the context after reading each chunk.
	#while file.get_position() < file.get_length():
		#var remaining = file.get_length() - file.get_position()
		#ctx.update(file.get_buffer(min(remaining, CHUNK_SIZE)))
	## Get the computed hash.
	#var res = ctx.finish()
	#if(res.hex_encode()==TARGET_SHA256_HASH):
		#print("SHA256 hash OK!")
#
#
## Thread must be disposed (or "joined"), for portability.
#func _exit_tree():
	#thread.wait_to_finish()

@onready var main: Node3D = $"."
var card3D_class = preload("res://cards/rendering/card_3d.tscn")
var viewport = preload("res://cards/rendering/card_2d_rendering_viewport.tscn")

func _ready():
	Globals.main = main
	Globals.camera_pivot = %CameraPivot
	Globals.player_perspective_camera = %PlayerPerspectiveCamera3D
	Globals.card_tray = %CardTray
	Card3D.initialize_card_texture()

func _on_card_3d_test_button_pressed() -> void:
	var library=Globals.card_library
	#var ids=["BGChaos","BGAllForOne","BGAmplify","BGBallLightning","BGBarrage","BGBeamCell",
	#"BGBlizzard","BGBuffer","BGCapacitor","BGChaos","BGChargeBattery",
	#"BGClaw","BGClaw2","BGColdSnap","BGCompileDriver","BGConsume",
	#"BGCoolheaded","BGCoreSurge","BGDarkness","BGDefend_Blue","BGDefragment"]
	#var ids=["BGCoreSurge","BGCoreSurge","BGCoreSurge","BGCoreSurge","BGCoreSurge","BGCoreSurge","BGCoreSurge","BGCoreSurge","BGCoreSurge","BGCoreSurge","BGCoreSurge"]
	var ids=[]
	var i=1;
	for key in library.card_list:
		if(i>=0 && i<=300):
			ids.append(key)
		i+=1;
		
	
	i=0
	var j=0
	for id:String in ids:		
		var c2rvp:Card2DRenderingViewport=viewport.instantiate()
		c2rvp.set_card(library.card_list.get(id));
		main.add_child(c2rvp)
		
		
		var c3=card3D_class.instantiate()
		c3.position=Vector3((i-10)*3,2+(j*4),1)
		c3.rotation=Vector3(PI/2,0,0)
		c3.scale=Vector3(0.75,0.75,0.75)
		#c3.transform.rotated()
		main.add_child(c3)
		c3.attach_2d_card_viewport(c2rvp)
		i+=1
		if(i>=25):
			i=0
			j+=1
		
	
	#%Card3D.test()
	##var path:String = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\SlayTheSpire\\desktop-1.0.jar"
	#%Card2D.bg_path="512/bg_attack_blue"
	##AtlasHelper.CARDUI.draw_to_canvas("1024/bg_attack_red",%Card2D,Vector2i(0,0))
	#%Card2D.queue_redraw()
	


func _on_draw_pile_test_button_pressed() -> void:
	var draw_pile = Globals.test_player.draw_pile
	if(!draw_pile.is_empty()):
		draw_pile.back().set_location(Globals.test_player.hand)
	else:
		%CardPile.temp_setup()
	
	pass # Replace with function body.


func _on_card_background_test_button_pressed() -> void:
	Card3D.initialize_card_texture()



func _on_glow_test_button_pressed() -> void:
	#CardGlowParticlesCollection.set_particle_appearance(%CardGlowParticlesCollection)
	pass

# It is not necessary to store a single mouse cursor in a persistent image,
# but we do so anyway because we'll be changing the cursor often.
var mouse_cursor_image:Image
func _on_cursor_test_button_pressed() -> void:
	mouse_cursor_image=Image.new()
	var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"
	var reader = ZIPReader.new()
	var err = reader.open(install_location)
	if err != OK:
		assert(false,"Failed to open desktop-1.0.jar")
		return
	mouse_cursor_image.load_png_from_buffer(reader.read_file("images/ui/cursors/gold2.png"))	
	reader.close()
	var window_size = DisplayServer.window_get_size()
	var ratio = window_size.y/1080.0
	print("Size: ",window_size," Ratio: ",ratio)
	mouse_cursor_image.resize(64*ratio,64*ratio)
	Input.set_custom_mouse_cursor(mouse_cursor_image,Input.CURSOR_ARROW,Vector2(0,0))
	# TODO: hotspot isn't exactly right. also need to adjust hotspot when cursor rotates, probably
	# TODO: must resize cursor if window size changes
