class_name MultiplayerManager extends Node2D

#TODO NEXT:
#	client calls send_serialized. 

#TODO: inconsistency in list names across various classes.
#	is it "play_queue" or "queued_plays" ?

var humans = []

# Lists (kept by all clients) of all pending plays sent by all characters.
var player_plays = {}
# Lists (kept by host only) of plays in chronological order.
var player_queues = {}
var players_by_id = {}
var player_ids = []
var next_player_id_index
# (The list of plays about to be executed is stored in PlayManager.)



func reset_queues():
	player_plays={}
	player_queues={}
	for player_id in player_ids:
		player_plays[player_id]={}
		player_queues[player_id]=[]
	next_player_id_index = 0


func _ready():
	#Placeholder 
	# -- this should be handled elsewhere
	# -- currently happens immediately after program boots up
	var my_id = multiplayer.get_unique_id()
	var human = AbstractHuman.new(my_id)
	
	register_player(0)
	
	reset_queues()
	
	


@rpc("any_peer","call_local","reliable",Globals.CHANNEL_GAMEPLAY)
func register_player(seat_number):
	var player_id = multiplayer.get_remote_sender_id()
	#TODO: this is entirely placeholder at the moment
	#	need to associate abstractplayer object with seat number first
	player_ids.append(player_id)
	players_by_id[player_id]=Globals.sandbox_player
	player_plays[player_id]={}
	player_queues[player_id]=[]

# Call from AbstractPlay.send_to_host
func send_serialized(type,args):
	var guid = PlayManager.get_guid_and_increment()
	_send_serialized2(guid,type,args)

# Private func! Call send_serialized instead!
@rpc("any_peer","call_local","reliable",Globals.CHANNEL_GAMEPLAY)
func _send_serialized2(guid,type,args):
	#print("send_serialized: ",multiplayer.get_remote_sender_id()," ",type," ",args)
	var player_id = multiplayer.get_remote_sender_id()
	
	# this is a dictionary, so we're checking whether key exists instead of whether value exists
	if(!players_by_id.has(player_id)):
		#TODO: definitely panic here
		# If possible, throw a "communication error" alert.
		# Not immediately obvious whether this can be exploited by a bad actor.
		return
	
	var player = players_by_id[player_id]
	
	# - when sending a play from client to host, include a GUID# for the play
	# - all players record the play and GUID# for later
	# - host just calls which GUID to play
		
	if(!player_plays.has(player_id)):
		player_plays[player_id]=[]
	player_plays[player_id][guid] = (AbstractPlay.create_play_from_args(player_id,guid,player,type,args))

	if(multiplayer.is_server()):
		if(!player_queues.has(player_id)):
			player_queues[player_id]=[]
		player_queues[player_id].append(guid)
	
	


@rpc("authority","call_local","reliable",Globals.CHANNEL_GAMEPLAY)
func receive_from_host(player_id,guid):
	print("receive from host: ",player_id," , ",guid)
	#var play = AbstractPlay.create_play_from_args(guid,player,type,args)
	if(!player_queues.has(player_id)):
		#TODO: communication error - invalid player_id received from host
		return
	if(!player_queues[player_id].has(guid)):
		#TODO: communication error - invalid play GUID received from host
		return
		
	var play = player_plays[player_id][guid]
	player_plays[player_id].erase(guid)
	print("this corresponds to play: ",play)
	
	Globals.play_manager.play_queue.append(play)



func _process(delta):
	#TODO: verify whether is_server() is exactly equivalent to is_host()
	#		and implement is_host() if it isn't
	
	# If current player queue has a play in it:
	#	Send the play to all clients
	# then cycle through to the next player. (If the next player's queue is empty, keep cycling.)	
	if(multiplayer.is_server()):
		if(!player_ids.is_empty()):		
			var current_player_id = player_ids[next_player_id_index]
			var queue = player_queues[current_player_id]
			var player = players_by_id[current_player_id]
			if(!queue.is_empty()):								
				var guid = queue.pop_front()
				receive_from_host(current_player_id,guid)
			
			next_player_id_index+=1
			if(next_player_id_index>=player_ids.size()):
				next_player_id_index=0
			
