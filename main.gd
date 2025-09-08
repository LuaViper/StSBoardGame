extends Node3D

func _on_hash_test_button_pressed() -> void:
	#var jar_manager = JarManager.new()	
	var path:String = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\SlayTheSpire\\desktop-1.0.jar"
	JarManager.load(path)
	
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
var card = preload("res://card_3d.tscn")
var viewport = preload("res://cards/card_2d_rendering_viewport.tscn")

func _on_card_3d_test_button_pressed() -> void:
	var library=CardLibrary.new()
	var ids=["BGAllForOne","BGAmplify","BGBallLightning","BGBarrage","BGBeamCell",
	"BGBlizzard","BGBuffer","BGCapacitor","BGChaos","BGChargeBattery",
	"BGClaw","BGClaw2","BGColdSnap","BGCompileDriver","BGConsume",
	"BGCoolheaded","BGCoreSurge","BGDarkness","BGDefend_Blue","BGDefragment"]
	
	var i=0
	for id:String in ids:		
		var c2rvp:Card2DRenderingViewport=viewport.instantiate()
		c2rvp.set_card(library.card_list.get(id));
		main.add_child(c2rvp)
		
		
		var c3:Card3D=card.instantiate()
		c3.position=Vector3((i-10)*3,2,1)
		c3.rotation=Vector3(PI/2,0,0)
		c3.scale=Vector3(0.75,0.75,0.75)
		#c3.transform.rotated()
		main.add_child(c3)
		c3.test(c2rvp)
		i+=1
		
	
	#%Card3D.test()
	##var path:String = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\SlayTheSpire\\desktop-1.0.jar"
	#%Card2D.bg_path="512/bg_attack_blue"
	##AtlasHelper.CARDUI.draw_to_canvas("1024/bg_attack_red",%Card2D,Vector2i(0,0))
	#%Card2D.queue_redraw()
	
