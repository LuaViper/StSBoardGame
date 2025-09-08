class_name CardLibrary

var card_list:Dictionary={}

func _init():
	var json=JSON.parse_string(FileAccess.get_file_as_string("res://cards/cards.json"))	
	for line in json:
		var id=line.id
		line.erase("id")
		card_list[id]=line
	
	for id in card_list:
		var card:Dictionary = card_list[id]
		if(card.has("quickimplementation")):
			var tags = card.quickimplementation.split(";")		
			print(id," ",tags)
			for tag in tags:
				var params = tag.split("=")
				#print(params[0])
				var path="res://cards/cardscript/card_tag_"+params[0].to_lower()+".gd"
				#print(path)
				if(ResourceLoader.exists(path)):
					pass
					#print(path," exists");
				else:
					print("Tag not found: ",params[0])
	
	
	
	
	#print(dict)
