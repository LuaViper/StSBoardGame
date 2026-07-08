class_name ActionManager

func add_to_bottom(action:AbstractGameAction)->void:
	# Adds the action to the very bottom of the action list.
	# For use with "non-automatic" actions only such as playing cards,
	#	potions, or enemy turns. Automatic actions should use the other functions.
	pass
	
func add_as_trigger(action:AbstractGameAction)->void:
	# 1. Add "Conditions for X were met" notice immediately following the currently tracked action.
	# 2. If a trigger section isn't part of the current action block, create one.
	# 3. Add the action (or action block) to the bottom of the trigger section.
	pass
