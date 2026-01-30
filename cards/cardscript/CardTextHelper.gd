class_name CardTextHelper

var tags=null

var RED_TEXT = -10132481
var GREEN_TEXT = 2147418367
var BLUE_TEXT = -2016482305
var GOLD = -272084481
var PURPLE = -293409025
var colors={"r"=RED_TEXT,"g"=GREEN_TEXT,"b"=BLUE_TEXT,"y"=GOLD,"p"=PURPLE}


func _init():
	print("CardTextHelper.init")
	tags={}
	#TODO: this stops working when the project is exported
	const TAGS_PATH = "res://cards/cardscript/tags/"
	var file_suffix
	if(OS.has_feature("editor")):
		#Running from editor
		file_suffix = ".gd"
	else:
		#Running from exported
		file_suffix = ".gdc"
	print("File suffix: ",file_suffix)
	var files=Globals.get_all_files_in_directory(TAGS_PATH)
	for file_path in files:
		print("Reading file ",file_path)
		if(file_path.begins_with(TAGS_PATH + "card_tag_") && file_path.ends_with(file_suffix)):
			var PREFIX_LENGTH = (TAGS_PATH+"card_tag_").length()
			var tag_name = file_path.substr(PREFIX_LENGTH,file_path.length()-PREFIX_LENGTH-file_suffix.length()).to_lower()
			print("Loading tag: ",tag_name)
			tags[tag_name]=load(file_path)


static func create_tag(key:String,card:AbstractCard,value,format)->CardTag:
	assert(Globals.card_text_helper.tags.has(key.to_lower()),"Nonexistent card tag key: "+key)
	var tag = Globals.card_text_helper.tags[key.to_lower()].new()
	tag.setup(key,card,value,format)
	return tag

func parse(text:String,card:AbstractCard)->String:
	#print("Parsing [tags] for card ",card.data.id)
	#print("Initial text: ",text)
	var result=""
	var regex = RegEx.new()
	regex.compile("\\[(.*?)\\]")
	var previous_end = 0
	for m in regex.search_all(text):
		var start = m.get_start()
		var end = m.get_end()
		var tagname = m.get_string(1)		#get string without []
		result += text.substr(previous_end, start - previous_end)
		var tag

		if(card.tags.has(tagname.to_lower())):
			tag=card.tags[tagname.to_lower()]
		if(tag):
			result += tag.get_text()
		else:
			if(tags.has(tagname.to_lower())):
				tag = tags[tagname.to_lower()].new().setup(tagname,card,null,{})
				result += tag.get_text()
			else:
				result+="{Missing tag: "+tagname+"}"
		previous_end=end
	result += text.substr(previous_end)	
	
	# remove double <NL>s
	text=result;result=""
	regex = RegEx.new()
	regex.compile("(?:<NL>)+")
	previous_end = 0
	for m in regex.search_all(text):
		var start = m.get_start()
		var end = m.get_end()
		result += text.substr(previous_end, start - previous_end)
		result += "\n"
		previous_end=end
	result += text.substr(previous_end)	
	
	# remove <NL>s next to <REMOVE_NL>
	text=result;result=""
	regex = RegEx.new()
	regex.compile("(\n)?<REMOVE_NL>(\n)?")
	previous_end = 0
	for m in regex.search_all(text):
		var start = m.get_start()
		var end = m.get_end()
		result += text.substr(previous_end, start - previous_end)
		result += ""
		previous_end=end
	result += text.substr(previous_end)		
	
	# remove trailing <NL>s
	if(result.begins_with("\n")):
		result=result.substr(1)
	if(result.ends_with("\n")):
		result=result.substr(0,result.length()-1)
		
	
	text=result;result=""
	regex = RegEx.new()
	regex.compile("<(.*?)>")
	previous_end = 0
	for m in regex.search_all(text):
		var start = m.get_start()
		var end = m.get_end()
		var icon_name=m.get_string(1)		#get string without <>
		result += text.substr(previous_end, start - previous_end)
		result += CardIconHelper.get_bbcode_tags(icon_name,card)
		previous_end=end
	result += text.substr(previous_end)	
	
	
	#Color tag search
	text=result;result=""
	regex = RegEx.new()
	regex.compile("#[A-Za-z0-9]+")
	previous_end = 0
	for m in regex.search_all(text):	
		var start = m.get_start()
		var end = m.get_end()
		var inner=m.get_string(0)
		#print("#: ",inner)
		result += text.substr(previous_end, start - previous_end)
		var color_tag=inner.substr(1,1)
		var word=inner.substr(2)
		#TODO: check color_tag instead of always using gold
		result+="[color="+integer_to_color(colors[color_tag]) +"]"
		result+=word
		result+="[/color]"
		
		previous_end=end
	result += text.substr(previous_end)		

	return result

static func integer_to_color(rgba_int: int) -> String:
	# Extract individual components using bitwise operations
	var r = (rgba_int >> 24) & 0xFF  # Red component (most significant byte)
	var g = (rgba_int >> 16) & 0xFF  # Green component
	var b = (rgba_int >> 8) & 0xFF   # Blue component
	var a = rgba_int & 0xFF         # Alpha component (least significant byte)

	# Convert 0-255 values to 0.0-1.0 range for Godot's Color constructor
	var color_r = "%x" % r
	var color_g = "%x" % g
	var color_b = "%x" % b
	var color_a = "%x" % a
	
	return "#"+color_r+color_g+color_b+color_a


func resize(text:String,card_:AbstractCard)->String:
	#TODO:
	return text
