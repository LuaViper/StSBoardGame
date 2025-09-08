#public CardTagHelper
extends Node

var tags=null

func _ready():
	tags={}
	tags["B"]=CardTagB.new()
	tags["CUSTOM"]=CardTagCustom.new()
	tags["DAZED"]=CardTagDazed.new()
	tags["DRAW"]=CardTagDraw.new()
	tags["E"]=CardTagE.new()
	tags["EALONE"]=CardTagEAlone.new()
	tags["EXHAUST"]=CardTagExhaust.new()
	tags["H"]=CardTagH.new()
	tags["LOSEHP"]=CardTagLoseHP.new()
	tags["M2"]=CardTagM2.new()
	tags["M"]=CardTagM.new()
	tags["MUSTEXHAUST"]=CardTagMustExhaust.new()
	tags["POWER"]=CardTagPower.new()
	tags["VULN"]=CardTagVuln.new()
	tags["WARCRY"]=CardTagWarcry.new()
	tags["WEAK"]=CardTagWeak.new()
	tags["XCOST"]=CardTagXCost.new()
	

static func get_tag(key:String)->CardTag:
	assert(CardTagHelper.tags[key.to_upper()],"Nonexistent card tag key: "+key.to_upper())
	return CardTagHelper.tags[key]
		
