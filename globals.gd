#global Globals
extends Node

#static func MAIN():
	#return FontHelper.get_tree().root.get_node("Main")

var jar_manager:JarManager
var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"

var main:Main
var card_text_helper:CardTextHelper
var card_library:CardLibrary

var test_player:AbstractPlayer

var camera_pivot:Marker3D
var player_perspective_camera:Camera3D
var card_tray

func _ready():
	jar_manager=JarManager.new()
	#must setup card_text_helper before card_library
	card_text_helper=CardTextHelper.new()
	card_library=CardLibrary.new()	
	test_player=AbstractPlayer.new()
	
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
#
#func event_position_to_card_tray_position(event_position:Vector2):
	#var ray_start = player_perspective_camera.project_ray_origin(event_position)
	#var ray_end = ray_start + player_perspective_camera.project_ray_normal(event_position)*1000
	#var world_space = player_perspective_camera.get_world_3d().direct_space_state
	#var result = world_space.intersect_ray(PhysicsRayQueryParameters3D.create(ray_start,ray_end))
	#if(result):
		#var local_position: Vector3 = card_tray.to_local(result.position)
		#return local_position
		
	
