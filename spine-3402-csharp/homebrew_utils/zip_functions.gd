class_name ZipFunctions

static var temp_prefix:int=0

static func extract_file_to_temp(path)->FileAccess:
	temp_prefix+=1
	var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"
	var reader = ZIPReader.new()
	var err = reader.open(install_location)
	if err != OK:
		assert(false,"Failed to open desktop-1.0.jar")
		return
	var pba:PackedByteArray = reader.read_file(path)
	var temp_file_access = FileAccess.create_temp(FileAccess.WRITE_READ,"sts_bg_"+str(temp_prefix),".tmp")
	if(!temp_file_access):
		assert(false,"Create temp failed: "+str(FileAccess.get_open_error()))
		return
	#copy zip file to temp file so FileAccess can read it
	temp_file_access.store_buffer(pba)
	#set temp cursor position to 0 so we can read from it
	temp_file_access.seek(0)
	reader.close()
	return temp_file_access

static func read_texture2d(path)->Texture2D:
	var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"
	var reader = ZIPReader.new()
	var err = reader.open(install_location)
	if err != OK:
		assert(false,"Failed to open desktop-1.0.jar")
		return
	var filetext = reader.read_file(path).get_string_from_utf8()
	var image = Image.new()
	image.load_png_from_buffer(reader.read_file(path))
	var texture:Texture2D=ImageTexture.create_from_image(image)
	reader.close()
	return texture
