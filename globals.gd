#global Globals
extends Node

#static func MAIN():
	#return FontHelper.get_tree().root.get_node("Main")

var jar_manager:JarManager
var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"

var card_text_helper:CardTextHelper
var card_library:CardLibrary

var camera_pivot:Marker3D

func _ready():
	jar_manager=JarManager.new()
	#must setup card_text_helper before card_library
	card_text_helper=CardTextHelper.new()
	card_library=CardLibrary.new()
	
	

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		jar_manager.cleanup()


#Would be static, but godot global scripts are weird with that.
func get_all_files_in_directory(path: String) -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# Recursively get files from subdirectories
				files.append_array(get_all_files_in_directory(path + file_name))
			else:
				files.append(path + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		assert(false,"Could not open directory: " + path)
	return files
