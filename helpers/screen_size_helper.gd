class_name ScreenSizeHelper

static var window_size
static var y_ratio
static func on_resize(new_size):
	window_size=new_size
	y_ratio = window_size.y/1080.0	
	if(MouseCursorHelper.mouse_cursor_image_base):
		MouseCursorHelper.resize_cursor()
	
