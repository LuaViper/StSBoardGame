class_name Card3DDragControl
extends Node3D

var card_tray = null
var card3d = null

# Mouseover
var hovered=false
# Picked up by holding LMB. Releasing LMB will select the card (below drop line) or play it (above drop line).
var dragged=false
# Permanently picked up via click or controller. Left-clicking will immediately release or play the card.
#	Note: all selected cards are also dragged.
var selected=false
# Frozen in place on screen while it waits to be played.
var queued = false

var is_hovering_drop_zone=false
var prev_is_hovering_drop_zone=false
const INITIAL_LERP_SPEED=0.1
var lerp_speed:float=INITIAL_LERP_SPEED

var target_position:Vector2

func _init():
	card_tray = Globals.card_tray

func _ready():
	#TODO: is this actually being used? %Card3D starts hidden and is never shown
	get_node("%Card3D").set_drag_control(self)

func _process(delta):
	if(!self.prev_is_hovering_drop_zone && self.is_hovering_drop_zone):
		card3d.flash_in_dropzone()
	
	self.prev_is_hovering_drop_zone = self.is_hovering_drop_zone
	
	#TODO: if associated card is no longer in hand, remove self from card tray 
	if(dragged):
		lerp_speed=lerp(lerp_speed,1.0,min(delta,1.0))
	else:
		lerp_speed=INITIAL_LERP_SPEED


#TODO NEXT: if the player releases the mouse button BELOW the drop zone, 
# 	the card is picked up as if it was quickly clicked once,
#	no matter how long or far the card has already been dragged

#TODO NEXT: when released in drop zone, card freezes where it is until it's queued to be played, 
# then moves to the middle of the screen and shrinks back down to its in-hand-not-mouseovered size
	# if a card is suddenly unplayable e.g. Normality, card goes directly from freeze position back to hand

func process_card_input_event(event,card):	
	if(self.queued):
		return
		
	if(event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT):
		if(event.pressed):			
			if(self.selected):
				release_card(self.is_hovering_drop_zone)				
			else:
				#print("Dragging ",self)
				self.dragged=true
				#%CardGlowParticlesCollection.get_node("%CardGlowParticles").set_emitting(true)		
				card_tray.card_pickup_y=get_viewport().get_mouse_position().y
				update_position_if_dragged(event)


func process_card_input(event,card):
	var prev_dragged=self.dragged
	var intend_to_play = false
	if(self.dragged):
		if(event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and !event.pressed):		
			#print("Stop dragging ",self," (release LMB)")	
			if(self.is_hovering_drop_zone):
				intend_to_play=true
				self.dragged=false
			else:
				self.selected=true
			#%CardGlowParticlesCollection.get_node("%CardGlowParticles").set_emitting(false)
		if(event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_RIGHT and event.pressed):
			#print("Stop dragging ",self," (press RMB)")
			self.dragged=false
		#if(event is InputEventMouseMotion):
			#if(card_tray.card_pickup_y!=null):
				#if(mouse_y>card_tray.card_pickup_y+260 || mouse_y>1080-50):
					#print("Stop dragging ",self," (cursor too low)")
					#drag_control.dragged=false						
	update_position_if_dragged(event)	
	if(prev_dragged && !dragged):
		#note that release_card sets dragged to false, which is redundant
		#we're doing this anyway so that we can call update_position before releasing the card
		release_card(intend_to_play)

func update_position_if_dragged(event):
	var mouse_y = get_viewport().get_mouse_position().y
	if(self.dragged):
		if(event is InputEventMouseMotion || event is InputEventMouseButton):		
			var tray_collision = get_mouse_intersect(event.position)
			if(tray_collision):
				var local_position = Globals.card_tray.to_local(tray_collision.position)
				self.position=local_position
				self.position.y=card_tray.get_front_of_tray_for_dragged_card()
			if(card_tray.card_pickup_y!=null):
				#Vanilla dropzone logic is defined in AbstractPlayer.java
				self.is_hovering_drop_zone=false
				if(mouse_y<card_tray.card_pickup_y-140):	
					self.is_hovering_drop_zone=true
				#TODO: if y is above exactly "300", card is hoverdropzone
				#TODO: if y is above Settings.CARD_DROP_END_Y, card is not hoverdropzone
					# (i.e. drop zone ENDS somewhere below the top of the screen)
				#TODO: if cursor overlaps a monster's hitbox or Settings.isControllerMode, card is automatically hoverdropzone
				if(mouse_y>card_tray.card_pickup_y+260):
					#print("drop!")
					#card too low
					pass
	#TODO: additionally, there's a bouncing target frame corner effect whenever a player/enemy is targeted
					
func get_mouse_intersect(mouse_position):
	var camera = get_viewport().get_camera_3d()
	var params = PhysicsRayQueryParameters3D.new()
	params.collision_mask = 0b0010   #layer 2
	params.from = camera.project_ray_origin(mouse_position)
	params.to = camera.project_position(mouse_position,10.0)
	var world_space = get_world_3d().direct_space_state
	var result = world_space.intersect_ray(params)
	return result	

func release_card(intend_to_play):
	self.dragged=false
	self.selected=false
	if(self.is_hovering_drop_zone && intend_to_play):
		assert(card_tray,"Card3DDragControl tried to play a card but there's no CardTray associated with it!")
		card_tray.queue_card(self)

		
	
	
