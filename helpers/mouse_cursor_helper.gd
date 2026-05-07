class_name MouseCursorHelper
extends Node

static var mouse_cursor_image_base:Image
static var mouse_cursor_image_rotated_base:Image
static var inspect_cursor_image_base:Image
static var inspect_cursor_image_rotated_base:Image
# Note that it is not necessary to store the resized cursor as a persistent image,
# but doing so will save an image.resize call each time the cursor changes.
static var mouse_cursor_image_resized:Image
static var mouse_cursor_image_rotated_resized:Image
static var inspect_cursor_image_resized:Image
static var inspect_cursor_image_rotated_resized:Image

#TODO LATER: rotated mouse cursor appears to be missing transparency around the edges

#func _input(event):
	#var y_ratio = ScreenSizeHelper.y_ratio
	##TODO: also check for inspect cursor(s)
	#if(y_ratio==null or !mouse_cursor_image_base or !mouse_cursor_image_rotated_base):
		#return	
		#
	#if(event is InputEventMouseButton):
		#if(event.button_index == MOUSE_BUTTON_LEFT):
			#if(event.is_pressed()):
				#Input.set_custom_mouse_cursor(mouse_cursor_image_rotated_resized,Input.CURSOR_ARROW,Vector2(0,4*y_ratio))				
			#elif(event.is_released()):
				#Input.set_custom_mouse_cursor(mouse_cursor_image_resized,Input.CURSOR_ARROW,Vector2(0,4*y_ratio))

static var current_mouse_cursor=null

func _process(_delta):
	var y_ratio = ScreenSizeHelper.y_ratio
	var offset = Vector2(0,4*y_ratio)
	if(y_ratio!=null):
		var target_cursor = mouse_cursor_image_resized
		if(Input.is_action_pressed("left_mouse_button")):
			target_cursor = mouse_cursor_image_rotated_resized
			offset = Vector2(4*y_ratio,7*y_ratio)
		if(target_cursor && target_cursor!=current_mouse_cursor):
			current_mouse_cursor=target_cursor
			Input.set_custom_mouse_cursor(current_mouse_cursor,Input.CURSOR_ARROW,offset)
	
static var rotator_class = preload("res://helpers/image_rotator.tscn")
	
static func load_cursors():
	mouse_cursor_image_base=Image.new()
	inspect_cursor_image_base=Image.new()
	var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"
	var reader = ZIPReader.new()
	var err = reader.open(install_location)
	if err != OK:
		assert(false,"Failed to open desktop-1.0.jar")
		return
	#TO DO: check read_file result isn't null
	mouse_cursor_image_base.load_png_from_buffer(reader.read_file("images/ui/cursors/gold2.png"))
	#TO DO: check read_file result isn't null
	inspect_cursor_image_base.load_png_from_buffer(reader.read_file("images/ui/cursors/magGlass2.png"))	
	reader.close()
	#mouse_cursor_image_rotated_base = await ImageRotator.rotate(mouse_cursor_image_base,-90.0*PI/180)
	#mouse_cursor_image_rotated_base = await ImageRotator.rotate(mouse_cursor_image_base,-36.0*PI/180)
	mouse_cursor_image_rotated_base = await ImageRotator.rotate(mouse_cursor_image_base,-6.0*PI/180)
	#mouse_cursor_image_rotated_base = await ImageRotator.rotate(mouse_cursor_image_base,0.0*PI/180)
	
	## WORKAROUND ##
	# cursor image loses detail after going through ImageRotator
	# 	so we redraw the original with ImageRotator 0 degrees
	# 	this way both cursors have the same amount of detail loss
	# TO DO LATER: can we prevent the cursor from losing detail? (we've already tried a bunch)
	mouse_cursor_image_base = await ImageRotator.rotate(mouse_cursor_image_base,0)
	
	
#static var foo=0
static func resize_cursor():	
	#TODO: also check for inspect cursor(s)
	if(!ScreenSizeHelper.window_size or !mouse_cursor_image_base or !mouse_cursor_image_rotated_base):
		return		
	var y_ratio=ScreenSizeHelper.y_ratio
	mouse_cursor_image_resized=mouse_cursor_image_base.duplicate()	
	var original_size=Vector2(64,64)
	mouse_cursor_image_resized.resize(original_size.x*y_ratio,original_size.y*y_ratio)
	
	mouse_cursor_image_rotated_resized=mouse_cursor_image_rotated_base.duplicate()	
	var rotated_size=mouse_cursor_image_rotated_resized.get_size()
	mouse_cursor_image_rotated_resized.resize(rotated_size.x*y_ratio,rotated_size.y*y_ratio)
