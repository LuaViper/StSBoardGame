class_name CardTag

var card=null

var name
var auto=true
var surrounding_nls=true
# minted value NEVER changes, even if the card is upgraded
var minted_value
var base_value
# displayed value includes all modifiers (e.g. after damage calculations)
var displayed_value
# misc can be AOE for hits or To Any Player for block
var misc=false
# TODO: replace misc with format, maybe rename to flags?
var format={}
	
func setup(name,card,value,format):
	self.name=name
	self.card=card
	self.minted_value=value
	self.base_value=value
	self.displayed_value=value
	self.auto=true if(name[0].to_upper()==name[0]) else false
	self.format=format
	return self

func get_text()->String:
	var surround="<NL>" if(surrounding_nls) else ""
	return surround+get_autotext()+surround

func get_autotext()->String:
	return "{ERROR: MISSING TAG AUTOTEXT: \""+name+"\"}"
	
func get_color_prefix()->String:
	if(format.has("NoColor")):
		return ""
	if(!displayed_value):
		return ""
	# override this for any tags where lower magic numbers are better
	elif(displayed_value>base_value):
		return "#g"
	elif(displayed_value<base_value):
		return "#r"
	else:
		return ""

func do():
	print("WARNING: called tag ",name,".do() but that tag's do() was never overridden")
