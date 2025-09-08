#global LocalizationHelper
extends Node

var CARDS = {}

func load_file(path):	
	var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"
	var reader = ZIPReader.new()
	var err = reader.open(install_location)
	if err != OK:
		assert(false,"Failed to open desktop-1.0.jar")
		return
	var base_dir = path.get_base_dir()
	var filetext = reader.read_file(path).get_string_from_utf8()
	return filetext

func _ready():
	var json=JSON.parse_string(load_file("localization/eng/cards.json"))
	CARDS["eng"]=json
