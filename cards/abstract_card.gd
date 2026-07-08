class_name AbstractCard

var data={}
var tags={}

static var next_guid = 0


var guid
# Internal_name is used for multiplayer comms.
# 	It's redundant with guid but helps us check for desync.
var internal_name

var location:CardGroup=null		#refers to hand, draw pile, discard pile, powers, reward pile, etc
var owner:AbstractPlayer = null

var is_glowing=false
var glow_timer=0.0
var glow_list=[]
var glow_color=TransparentEffects.BLUE_BORDER_GLOW_COLOR
var flash_list=[]

var energy_cost

func setup(data_:Dictionary):
	self.data=data_
	#TODO LATER: this breaks if next_guid rolls over max int
	self.guid = next_guid; next_guid+=1
	self.internal_name = self.data.id
	#print("_init ",data.id)
	if(data.has("quickimplementation")):
		load_quick_implementation()
	#print(get_text())
	return self

func make_copy():
	return AbstractCard.new().setup(self.data)

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
			var tag=CardTextHelper.create_tag(name,self,value,format)
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


func get_energy_cost(player):
	return energy_cost


func cannot_be_played(player:AbstractPlayer):
	# Return value may contain an error message for the player.
	
	#TODO:
	# 

	return false

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

func get_title()->String:
	#TODO: upgrade check
	#TODO: vgname isn't card_title -- vgname should be a link to an entry in localization/eng/cards.json
	if(data.vgname!="SPECIAL"):
		return LocalizationHelper.CARDS.eng[data.vgname].NAME
	else:
		#TODO: we should probably do a more sophisticated check
		return "Golden Ticket"

func _to_string()->String:
	var name = get_title()	
	#TODO: anything else that might affect the card's name
	return name

# Private function!
# (we currently call this from a couple other places but for testing purposes only)
# Use the specific functions to change a card's location --
#	-- this function is not responsible for calling trigger effects
func _set_location(location):
	var prev_location=self.location
	if(prev_location):
		assert(prev_location.has(self),"Card was moved from one location to another, but the previous location had no record of this card")
		prev_location.erase(self)
	#TODO: if card has a card3D, and card3D has a drag_control, remove the drag control
	self.location = location
	if(location!=null):
		location.append(self)
	#TO DO LATER: use a CardGroup class for locations so we can give them a name property
	#print("Card ",self," moved from ",prev_location," to ",location)

func move_to_hand():
	_set_location(owner.hand)

func move_to_discard(sly=false):
	if(sly):
		if(location==owner.hand):
			#TODO: trigger Sly effects
			pass
	_set_location(owner.discard_pile)
	
func on_sly():
	#override
	pass
	
func exhausting_triggers_exhaust_effects():
	#TODO: check physical copy, ruleset, etc
	#RAW: only physical cards can exhaust (matches VG)
	#RAI: playing a copied card that says "exhaust" counts as an exhaust
	return true
	
func move_to_exhaust():
	if(exhausting_triggers_exhaust_effects()):
		_trigger_exhaust_powers()
		on_exhaust()
	_set_location(owner.exhaust_pile)

func _trigger_exhaust_powers():	
	pass

func move_to_top_of_draw_pile():
	pass

func on_exhaust():
	#override
	pass
	
func get_cleanup_actions():
	#by default, move_to_discard
	return [MoveToDiscardAction.new(self)]
	pass
