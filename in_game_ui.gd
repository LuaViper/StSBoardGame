extends Panel

var top_bar_image=Image.new()

func _ready():
	load_top_bar()
	# reminder: anchors AND pivots need to be set correctly and in the correct order in editor
	#TODO: calculate scale for each UI element (and recalculate when screen is resized)
		#top bar image should be fit to screen width
	%TopBarImage.scale=Vector2(1,1)
	#%TopBarImage.scale=Vector2(0.5,0.5)

	
	

func load_top_bar():
	top_bar_image=Image.new()

	var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"
	var reader = ZIPReader.new()
	var err = reader.open(install_location)
	if err != OK:
		assert(false,"Failed to open desktop-1.0.jar")
		return
	#TO DO: check read_file result isn't null
	top_bar_image.load_png_from_buffer(reader.read_file("images/ui/topPanel/bar.png"))
	reader.close()
	
	var panel = %TopBarImage
	var stylebox:StyleBoxTexture = StyleBoxTexture.new()
	stylebox.texture = ImageTexture.create_from_image(top_bar_image)
	#stylebox.bg_color = Color.GREEN
	#stylebox.bg_color.a = 0.5
	panel.add_theme_stylebox_override(Globals.STYLEBOX_THEME_DEFAULT_NAME,stylebox)


#func _on_ui_test_button_pressed() -> void:
	#load_top_bar()
	#%UITestButton.hide()
