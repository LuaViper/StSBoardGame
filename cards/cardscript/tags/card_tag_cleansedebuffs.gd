class_name CardTagCleanseDebuffs extends CardTag

func get_autotext()->String:
	var from_player = "any player" if(!misc) else "all players"
	match displayed_value:
		"Self":
			from_player="your character"
		"Any":
			from_player="any player"
		"All":
			from_player="all players"
		_:
			from_player="(INVALID CleanseDebuffs VALUE "+displayed_value+")"
	return "Remove all <WEAK_ICON><VULN_ICON><NL>from "+from_player+"."
