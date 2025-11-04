class_name AbstractCard

var data={}
var tags={}

func setup(data:Dictionary):
	self.data=data
	#print("_init ",data.id)
	if(data.has("quickimplementation")):
		load_quick_implementation()
	#print(get_text())
	return self

func load_quick_implementation():
	var taglist = data.quickimplementation.split(";")
	for statement in taglist:
		if(statement!=""):
			var tokens = statement.split("=")
			var name = tokens[0]
			var value = null
			var format = {}
			if(tokens.size()>1):
				value = tokens[1]
				var tokens2 = value.split(":")
				if(tokens2.size()>1):
					value=tokens2[0]
					for i in range(1,tokens2.size()):
						format[tokens2[i]]=true
			var tag=Globals.card_text_helper.create_tag(name,self,value,format)
			tags[name.to_lower()]=tag
	#TODO: upgrade logic probably gets handled here too
		
func get_text():
	var result="{ERROR: MISSING TEXT}"
	if(data.has("text")):
		if(data.text=="[Auto]"):
			result=""
			for key in tags:
				var tag=tags[key]
				if(tag.auto):
					result+="["+tag.name+"]"
		else:
			result=data.text
	
	result = Globals.card_text_helper.parse(result,self)
	result = Globals.card_text_helper.resize(result,self)
	return result


func play():
	for key in tags:
		var tag=tags[key]
		if(tag.auto):
			tag.do()

func custom():
	print("WARNING: Custom action was called on ",data.id," but no custom action exists for that card")

func power():
	print("WARNING: Power action was called on ",data.id," but no power action exists for that card")


func hit_color_tags(text:String):
	#TODO: surround with color tags depending on hit amt
	return text

func block_color_tags(text:String):
	#TODO:
	return text

func magic_color_tags(text:String):
	#TODO:
	return text
