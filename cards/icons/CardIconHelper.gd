class_name CardIconHelper

static func get_bbcode_tags(key:String, card:AbstractCard):
	match key.to_lower():
		"hit_icon":	
			return "[img width=24]res://cards/icons/images/hit.png[/img]"
		"block_icon":	
			return "[img width=24]res://cards/icons/images/block.png[/img]"
		"aoe_icon":	
			return "[img width=24]res://cards/icons/images/aoe.png[/img]"
		"vuln_icon":	
			return "[img width=24]res://cards/icons/images/vuln.png[/img]"
		"weak_icon":	
			return "[img width=24]res://cards/icons/images/weak.png[/img]"
		"12":
			return "[img width=24]res://cards/icons/images/die1.png[/img]" \
				+ "[img width=24]res://cards/icons/images/die2.png[/img]"
		"34":
			return "[img width=24]res://cards/icons/images/die3.png[/img]" \
				+ "[img width=24]res://cards/icons/images/die4.png[/img]"
		"56":
			return "[img width=24]res://cards/icons/images/die5.png[/img]" \
				+ "[img width=24]res://cards/icons/images/die6.png[/img]"
		"123":
			return "[img width=24]res://cards/icons/images/die1.png[/img]" \
				+ "[img width=24]res://cards/icons/images/die2.png[/img]" \
				+ "[img width=24]res://cards/icons/images/die3.png[/img]" 
		"456":
			return "[img width=24]res://cards/icons/images/die4.png[/img]" \
				+ "[img width=24]res://cards/icons/images/die5.png[/img]" \
				+ "[img width=24]res://cards/icons/images/die6.png[/img]"
		"3":
			return "[img width=24]res://cards/icons/images/die3.png[/img]"				
		"4":
			return "[img width=24]res://cards/icons/images/die4.png[/img]"			
		"energy_icon":			
			#TODO: check card color
			match card.data.color:
				"BGRed":
					return "[img width=24]res://cards/icons/images/energyR.png[/img]"
				"BGGreen":
					return "[img width=24]res://cards/icons/images/energyG.png[/img]"
				"BGBlue":
					return "[img width=24]res://cards/icons/images/energyB.png[/img]"			
				"BGPurple":
					return "[img width=24]res://cards/icons/images/energyP.png[/img]"
				_:
					return "[img width=24]res://cards/icons/images/energyR.png[/img]"
		"str_icon":			
			return "[img width=24]res://cards/icons/images/str.png[/img]"			
		"shiv_icon":			
			return "[img width=24]res://cards/icons/images/shiv.png[/img]"			
		"poison_icon":			
			return "[img width=24]res://cards/icons/images/poison.png[/img]"			
		"miracle_icon":			
			return "[img width=24]res://cards/icons/images/miracle.png[/img]"			
		"dazed_icon":			
			return "[img width=24]res://cards/icons/images/daze.png[/img]"			
		"slimed_icon":			
			return "[img width=24]res://cards/icons/images/slime.png[/img]"			
		"burn_icon":			
			return "[img width=24]res://cards/icons/images/burn.png[/img]"			
			
		_:
			return "{UNK ICON "+key+"}"
