class_name CardTagH2 extends CardTag

#TODO: decide ONE OF
# decision cards such as Whirlwind or Iron Wave+,
#	which are expected to ask for cost or effect before choosing a target,
#	should clear ALL decisions already made if one decision is invalid
# OR
# decision cards must always ask for target first before any other decisions
# OR
# don't worry about it, and if a player has to retarget a card, so be it
#	(note that something tangentially related happens in VG if you queue a decision card followed by a target;
#	 you don't get to retarget after making the decision)
#
# additionally, we have not yet considered how Predator interacts with other players
#	who are unexpectedly forced to -1 Energy vs Awakened One when they draw 2

func setup(name,card,value,format):
	self.surrounding_nls=false
	if(value.begins_with("AOE")):
		value=value.substr(3)
		misc=true;
	super.setup(name,card,value,format)
	return self

func get_autotext()->String:
	var aoe = "" if(!misc) else "<AOE_ICON>"
	return aoe+self.get_color_prefix()+displayed_value+"<HIT_ICON>"
