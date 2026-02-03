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
		if(!card_control.dragged):
			set_placeholder_position_by_index(card_control,i)	
	var angle_range = 50.0 - (10 - hand_size) * 5.0
	var increment_angle = angle_range / hand_size
	for i in range(hand_size):
		card_control=placeholders.get(i)
		card_control.set_rotation_degrees(Vector3(
			0,
			angle_range/2.0 - increment_angle*i - increment_angle/2.0,
			0))			
		card_control.scale=Vector3(0.7,0.7,0.7)
	for i in range(hand_size):
		card_control=placeholders.get(i)
		#TODO: ignore hover if player is dragging a different card
		if(card_control.hovered || card_control.dragged):
			hover_card_push(card_control)		
			card_control.rotation=Vector3(0,0,0)
			card_control.scale=Vector3(1,1,1)
			if(!card_control.dragged):
				card_control.position.z=get_bottom_of_screen_for_hovered_card()
	

		
	var _PH = delta
	
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
		hand_controls.get(i).position.x += PIXEL_SCALE * IMG_WIDTH_S * push_amount
		push_amount*=0.25
	push_amount = 0.4
	if(hand_size==2): push_amount=0.2 
	elif(hand_size==3 || hand_size==4): push_amount=0.27
	for i in range(card_index-1,-1,-1):
		hand_controls.get(i).position.x -= PIXEL_SCALE * IMG_WIDTH_S * push_amount
		push_amount*=0.25
	card_controller.position.y=get_front_of_tray_for_dragged_card()

func get_front_of_tray_for_dragged_card():
	#TO DO LATER: check hand size
	return 0.5

	
func get_bottom_of_screen_for_hovered_card():
	#TO DO LATER: check screen dimensions? (maybe not necessary with canvas stretch mode)
	# this value is in local coordinates, not viewport coordinates!
	return 3.05
	
func release_card():
	#NYI: hide orb evoke values
	passed_hesitation_line = false
	in_single_target_mode = false
	#NYI: unhide game cursor (NYI: also *hide* cursor when card goes into enemy targeting mode)
	#NYI: if card is usable, begin glowing (not sure why this is here--card never stops glowing when picked up)
