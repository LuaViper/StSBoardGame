class_name TextureAtlas extends Node

enum {FILE,ROTATE,XY,SIZE}
var data = Dictionary()
var files = Dictionary()	#stores Images -- rename when possible
var textures = Dictionary()	#stores ImageTextures

func load_file(path):	
	var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"
	var reader = ZIPReader.new()
	var err = reader.open(install_location)
	if err != OK:
		assert(false,"Failed to open desktop-1.0.jar")
		return
	var base_dir = path.get_base_dir()
	var filetext = reader.read_file(path).get_string_from_utf8()
	var lines=filetext.split("\n",false)
	var active_file=""
	var active_key=""
	for line in lines:
		if(line.contains(".png")):			
			active_key=""
			active_file=base_dir+"/"+line
			#print("Recording file ",active_file)
			var image = Image.new()
			image.load_png_from_buffer(reader.read_file(active_file))
			files.set(active_file,image)
			var texture = ImageTexture.create_from_image(image)
			textures.set(active_file,texture)
		elif(line.contains(":") and active_key):
			if(line.contains("rotate:")):
				var suffix=line.split(":")[1]
				var rotate=suffix.trim_prefix(" ").trim_suffix(" ")
				data.get(active_key).set(ROTATE,rotate)
			if(line.contains("xy:")):
				var suffix=line.split(":")[1]
				var xy=Vector2i(int(suffix.split(",")[0]),int(suffix.split(",")[1]))
				data.get(active_key).set(XY,xy)
			if(line.contains("size:")):
				var suffix=line.split(":")[1]
				var size=Vector2i(int(suffix.split(",")[0]),int(suffix.split(",")[1]))
				data.get(active_key).set(SIZE,size)	
		else:
			active_key=line
			data.set(active_key,Dictionary());
			data.get(active_key).set(FILE,active_file)
	reader.close()

func get_rect2(key)->Rect2:
	assert(data.has(key),"Tried to get Rect2 of nonexistent key "+key+" from atlas "+str(self))
	var x=data.get(key).get(XY).x
	var y=data.get(key).get(XY).y
	var wid=data.get(key).get(SIZE).x
	var hgt=data.get(key).get(SIZE).y
	return Rect2(x,y,wid,hgt)

func get_image(key)->Image:
	assert(data.has(key),"Tried to get Image of nonexistent key "+key+" from atlas "+str(self))
	var filename=data.get(key).get(FILE)
	return files.get(filename)

func get_texture(key)->Image:
	assert(data.has(key),"Tried to get Image of nonexistent key "+key+" from atlas "+str(self))
	var filename=data.get(key).get(FILE)
	return textures.get(filename)	

func get_rotate(key)->bool:
	assert(data.has(key),"Tried to get rotate of nonexistent key "+key+" from atlas "+str(self))
	return (data.get(key).get(ROTATE)=="true")
		
func draw_to_image(key,dest_image,dest_offset,scale=1.0):
	assert(data.has(key),"Tried to draw nonexistent key "+key+" from atlas "+str(self))
	var x=data.get(key).get(XY).x
	var y=data.get(key).get(XY).y
	var wid=data.get(key).get(SIZE).x
	var hgt=data.get(key).get(SIZE).y
	var filename=data.get(key).get(FILE)
	var src=files.get(filename)
	#TODO: also check ROTATE
	if(scale!=1.0):
		x*=scale;
		y*=scale;
		wid*=scale;
		hgt*=scale;
		#copy src, don't modify the original
		src=src.get_region(Rect2i(0,0,src.get_width(),src.get_height()))
		src.resize(src.get_width()*2,src.get_height()*2)	#wait why is this *2 instead of *scale?
	dest_image.blend_rect(src,Rect2i(x,y,wid,hgt),dest_offset)

func draw_to_canvas(key,dest_canvas:CanvasItem,dest_xy:Vector2):	
	assert(data.has(key),"Tried to draw nonexistent key "+key+" from atlas "+str(self))
	var x=data.get(key).get(XY).x
	var y=data.get(key).get(XY).y
	var wid=data.get(key).get(SIZE).x
	var hgt=data.get(key).get(SIZE).y
	var filename=data.get(key).get(FILE)
	var src:ImageTexture=textures.get(filename)
	#if(key=="512/frame_skill_uncommon"):
		#print("Drawing: ")
		#print(filename," ",src)
		#print(x," ",y," ",wid," ",hgt)
		#print(dest_xy.x," ",dest_xy.y," ",wid," ",hgt)
	dest_canvas.draw_texture_rect_region(src,Rect2(dest_xy.x,dest_xy.y,wid,hgt),Rect2(x,y,wid,hgt))

#func draw_to_text(key,dest_textbox:RichTextLabel):
	#assert(data.has(key),"Tried to draw nonexistent key "+key+" from atlas "+str(self))
	#var x=data.get(key).get(XY).x
	#var y=data.get(key).get(XY).y
	#var wid=data.get(key).get(SIZE).x
	#var hgt=data.get(key).get(SIZE).y
	#var filename=data.get(key).get(FILE)
	#var src:ImageTexture=textures.get(filename)
	#dest_textbox.add_image(src,0,0,Color.WHITE,5,Rect2(x,y,wid,hgt),"testkey")
	
#func get_bbcode_tags(key):
	#assert(data.has(key),"Tried to draw nonexistent key "+key+" from atlas "+str(self))
	#var x=data.get(key).get(XY).x
	#var y=data.get(key).get(XY).y
	#var wid=data.get(key).get(SIZE).x
	#var hgt=data.get(key).get(SIZE).y
	#var filename=data.get(key).get(FILE)
	#var src:ImageTexture=textures.get(filename)
	#ResourceSaver.save(src,'user://img.res')
	#var tags = "[img width=28 region="+str(x)+","+str(y)+","+str(wid)+","+str(hgt)+"]user://img.res[/img]"
	#return tags
