

#TODO should we rename PlayManager to PlayHelper?

class_name PlayManager

enum {CARD_PLAY}

# List of plays received from the multiplayer game host.
# These are executed one at a time
var play_queue = []

static var next_play_guid = 0


func is_host():
	#TODO:
	if(true): return true
	pass

static func get_guid_and_increment():
	#TODO: this could break if it rolls over max_int
	var result = next_play_guid
	next_play_guid += 1
	return result


# note that PlayManager does NOT extend Node, so it will not call _process automatically
func _process(delta):
	# Take the next play at the head of the queue
	# Check if it can be played
	#	If it can't be played, run on_unplayable()
	#	Otherwise, play it
	
	if(!play_queue.is_empty()):
		var play = play_queue.pop_front()
		if(play.is_play_blocked()!=false):
			play.on_unplayable()
		else:
			play.do()
	
	pass
