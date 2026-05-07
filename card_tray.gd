extends StaticBody3D

#TO DO LATER: Card3D.MousePickingCollision's shape size is only approximate -- find exact size if possible
#TO DO LATER: consider searching "godot position a flat plane so the edges align with the viewport"

#Reminder: Card Holder Rack is designed for a birds eye view.
#	Cards move on X and Z coordinates.
#	Rack is rotated 90 degrees on camera attachment (in addition to scaling down to 0.25x).

var card_control = preload("res://card_3d_drag_control.tscn")

const IMG_WIDTH_S = 300.0 * 0.7
const PIXEL_SCALE = 0.011	#TODO:

var CARD_POSITIONS=[]
var card_pickup_y = null
#Determines if the player ever moved the card past the drop line. Persists if moved back.
var passed_hesitation_line = false
var in_single_target_mode = false

var queued_cards = []


func _init():
	#0
	CARD_POSITIONS.append([])
	#1
	CARD_POSITIONS.append([Vector2(0,0)]) 
	#2
	CARD_POSITIONS.append([Vector2(-0.47,0),Vector2(0.53,0)])
	#3
	CARD_POSITIONS.append([Vector2(-0.9,20),Vector2(0,0),Vector2(0.9,20)])
	#4
	CARD_POSITIONS.append([Vector2(-1.36,0),Vector2(-0.46,-10),Vector2(0.46,-10),Vector2(1.36,0)])
	#5
	CARD_POSITIONS.append([Vector2(-1.7,25),Vector2(-0.9,0),Vector2(0,-10),Vector2(0.9,0),Vector2(1.7,25)])
	for list in CARD_POSITIONS:
		#we can't use a foreach on list as vectors will be copied byval instead of byref
		for i in range(list.size()):
			list[i].x *= PIXEL_SCALE * IMG_WIDTH_S
			list[i].y *= PIXEL_SCALE


func _process(delta):	
	var placeholders = %CardPlaceholders.get_children()
	#print(delta," ",TEMP_HAND_SIZE)
	#for i in range(placeholders.size(),TEMP_HAND_SIZE):
		#var new_placeholder = card_control.instantiate()
		#%CardPlaceholders.add_child(new_placeholder)
		#new_placeholder.scale = Vector3(0.7,0.7,0.7)

	placeholders = %CardPlaceholders.get_children()
	var card_control
	var hand_size = placeholders.size()
	for i in range(hand_size):
		card_control=placeholders.get(i)
		if(!card_control.dragged && !card_control.queued):
			set_placeholder_position_by_index(card_control,i)	
	var angle_range = 50.0 - (10 - hand_size) * 5.0
	var increment_angle = angle_range / hand_size
	for i in range(hand_size):
		card_control=placeholders.get(i)
		if(!card_control.queued):
			card_control.set_rotation_degrees(Vector3(
				0,
				angle_range/2.0 - increment_angle*i - increment_angle/2.0,
				0))
			card_control.scale=Vector3(0.7,0.7,0.7)
	for i in range(hand_size):
		card_control=placeholders.get(i)
		#TODO: ignore hover if player is dragging a different card
		if((card_control.hovered || card_control.dragged) && !card_control.queued):
			hover_card_push(card_control)
			card_control.rotation=Vector3(0,0,0)
			card_control.scale=Vector3(1,1,1)
			if(!card_control.dragged):
				card_control.position.z=get_bottom_of_screen_for_hovered_card()
			else:					
				pass
		if(card_control.queued):
			#adjust card_control's position to avoid zfighting when multiple cards are queued at once
			card_control.position.y=get_front_of_tray_for_queued_card(card_control)
		
	var _PH = delta
	
	#TODO: move this to a PlayerActionManager. potions take priority over queued cards, for example.

	if(queued_cards.has(0)):
		card_control=queued_cards.get(0)
	if(card_control):
		#TODO: "is card still playable?" check goes here
		if(card_control.play_timer==null):
			var can_be_played = card_control.card3d.can_be_played()
			if(can_be_played != true):
				#TODO: display error message if applicable
				card_control.queued=false
				queued_cards.pop_front()
			else:
				card_control.play_timer=0.5
		
		if(card_control.play_timer!=null):
			#TODO: card gets Officially Played here
			# card leaves hand
			# if the player is under a "next card copies" effect,
			card_control.play_timer-=delta
			card_control.rotation=Vector3(0,0,0)
			card_control.scale=Vector3(0.7,0.7,0.7)
			card_control.position=get_center_of_screen_for_played_card()
			if(card_control.play_timer<0):
				card_control.play_timer=null
				#TODO: time to think about playing the card
				#if the player is under a "next card copies" effect, we need to deal with that first
				# in vanilla, copied cards wait to the left of the original card in the center of the screen
				# copies spawn from the "queued" position and move directly to middle at the same time the original does
				#  in board game, copies are played first, so original will wait on the left
				# in vanilla, "is card playable?" check occurs... we don't know and don't card
				#  because in board game, playable check needs to occur before copies are spawned
				
			
				
			
			#TODO NEXT: attempt to play the card
			#TODO: at some point in the near future we need card_controls to track which position they are in the player's hand,
				# and update when cards to the left are removed/added
	
	
func set_placeholder_position_by_index(drag_control,index=null):
	var hand_size = %CardPlaceholders.get_children().size()
	#can't use ternary: index==null is invalid; index==0 is *not*
	if(index==null): index=hand_size-1
	drag_control.position = Vector3(
			CARD_POSITIONS[hand_size][index].x,
			#index*PIXEL_SCALE,
			index*0.03,
			#index*0.3,
			CARD_POSITIONS[hand_size][index].y+4)
	#print(index," out of ",hand_size,": ",CARD_POSITIONS[hand_size][index].x,"  ,   ",CARD_POSITIONS[hand_size][index].y)
	#print(index," out of ",hand_size,": ",index*0.03)
	
func create_drag_control():
	var new_placeholder = card_control.instantiate()
	%CardPlaceholders.add_child(new_placeholder)	
	#the following line adds the card to the left side of hand instead of right side	
	#TO DO LATER: only during initial draw while draw pile is on the left side of screen
	%CardPlaceholders.move_child(new_placeholder,0)
	#TO DO LATER: cards added to right side of hand suddenly pop through the rest of hand. undesirable
	new_placeholder.scale = Vector3(0.7,0.7,0.7)
	set_placeholder_position_by_index(new_placeholder)
	return new_placeholder

func hover_card_push(card_controller):
	var hand_controls = %CardPlaceholders.get_children()
	var hand_size = hand_controls.size()
	if(hand_size<=1): return
	var card_index = hand_controls.find(card_controller)
	var push_amount = 0.4
	if(hand_size==2): push_amount=0.2 
	elif(hand_size==3 || hand_size==4): push_amount=0.27
	for i in range(card_index+1,hand_size):
		if(!hand_controls.get(i).queued):
			hand_controls.get(i).position.x += PIXEL_SCALE * IMG_WIDTH_S * push_amount
			push_amount*=0.25
	push_amount = 0.4
	if(hand_size==2): push_amount=0.2 
	elif(hand_size==3 || hand_size==4): push_amount=0.27
	for i in range(card_index-1,-1,-1):
		if(!hand_controls.get(i).queued):
			hand_controls.get(i).position.x -= PIXEL_SCALE * IMG_WIDTH_S * push_amount
			push_amount*=0.25
	card_controller.position.y=get_front_of_tray_for_dragged_card()

func get_front_of_tray_for_queued_card(card_control):
	var index = queued_cards.find(card_control)
	assert(index!=-1,"Tried to z-position queued card_control "+card_control.to_string()+", but it's not in the queued cards list")
	return 0.4+index*0.01
	
func get_front_of_tray_for_dragged_card():
	#TO DO LATER: check hand size
	# This number should be sufficiently larger than the queued_card function that dragged cards will always appear in front.
	return 0.5
	
func get_bottom_of_screen_for_hovered_card():
	#TO DO LATER: check screen dimensions? (maybe not necessary with canvas stretch mode)
	# this value is in local coordinates, not viewport coordinates!
	return 3.05

func get_center_of_screen_for_played_card():
	# the 0.7 should be sufficiently larger than front of tray for dragged card.
	return Vector3(0,0.7,0)
	
#func release_card():
	##NYI: hide orb evoke values
	#passed_hesitation_line = false
	#in_single_target_mode = false
	##NYI: unhide game cursor (NYI: also *hide* cursor when card goes into enemy targeting mode)
	##NYI: if card is usable, begin glowing (not sure why this is here--card never stops glowing when picked up)

func queue_card(card_control):	
	card_control.queued=true
	queued_cards.append(card_control)
