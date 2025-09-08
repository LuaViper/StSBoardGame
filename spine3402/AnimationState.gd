class_name AnimationState

var data:AnimationStateData = null
var tracks = []
var events = []
var listeners = []
var time_scale = 1.0
var track_entry_pool:Pool

func _init(data:AnimationStateData = null):
	self.track_entry_pool = Pool.new()
	self.data=data

func update(delta):
	delta *= time_scale
	for i in range(tracks.size()):
		var current = tracks[i]
		if current != null:
			var next = current.next
			if next != null:
				var nextTime = current.lastTime - next.delay
				if nextTime >= 0.0:
					var nextDelta = delta * next.time_scale
					next.time = nextTime + nextDelta
					current.time += delta * current.time_scale
					set_current(i, next)
					next.time -= nextDelta
					current = next
			elif not current.loop and current.lastTime >= current.endTime:
				clear_track(i)
				continue
			current.time += delta * current.time_scale
			if current.previous != null:
				var previousDelta = delta * current.previous.time_scale
				current.previous.time += previousDelta
				current.mixTime += previousDelta

func apply(skeleton:Skeleton):
	var events_local = events
	var listenerCount = listeners.size()
	for i in range(tracks.size()):
		var current = tracks.get(i)
		if current != null:
			events_local.clear()
			var time_val = current.time
			var lastTime = current.last_time
			var endTime = current.end_time
			var loop = current.loop
			if not loop and time_val > endTime:
				time_val = endTime
			var previous = current.previous
			if previous == null:
				current.animation.mix(skeleton, lastTime, time_val, loop, events_local, current.mix)
			else:
				var previousTime = previous.time
				if not previous.loop and previousTime > previous.endTime:
					previousTime = previous.end_time
				previous.animation.apply(skeleton, previousTime, previousTime, previous.loop, null)
				var alpha = (current.mix_time / current.mixDuration) * current.mix
				if alpha >= 1.0:
					alpha = 1.0
					track_entry_pool.free_(previous)
					current.previous = null
				current.animation.mix(skeleton, lastTime, time_val, loop, events_local, alpha)
			
			for event in events_local:
				if current.listener != null:
					current.listener.event(i, event)
				for j in range(listenerCount):
					listeners[j].event(i, event)
			
			#if (loop and (lastTime % endTime > time_val % endTime)) or ((not loop) and (lastTime < endTime and time_val >= endTime)):
			if (loop and (fmod(lastTime, endTime) > fmod(time_val, endTime))) or ((not loop) and (lastTime < endTime and time_val >= endTime)):
				var completions = int(time_val / endTime)
				if current.listener != null:
					current.listener.complete(i, completions)
				for j in range(listeners.size()):
					listeners[j].complete(i, j)
			
			current.last_time = current.time

func clear_tracks():
	for i in range(tracks.size()):
		clear_track(i)
	tracks.clear()

func clear_track(track_index:int):
	if track_index < tracks.size():
		var current = tracks[track_index]
		if current != null:
			if current.listener != null:
				current.listener.end(track_index)
			for l in listeners:
				l.end(track_index)
			tracks[track_index] = null
			free_all(current)
			if current.previous != null:
				track_entry_pool.free_(current.previous)

func free_all(entry):
	while entry != null:
		var nxt = entry.next
		track_entry_pool.free_(entry)
		entry = nxt

func expand_to_index(index):
	if index < tracks.size():
		return tracks[index]
	else:
		#original java uses tracks.ensureCapacity
		var current_size = tracks.size()
		for i in range(index - current_size + 1):
			tracks.append(null)
		return null

func set_current(index, entry):
	var current = expand_to_index(index)
	if current != null:
		var previous = current.previous
		current.previous = null
		if current.listener != null:
			current.listener.end(index)
		for l in listeners:
			l.end(index)
		entry.mixDuration = data.getMix(current.animation, entry.animation)
		if entry.mixDuration > 0.0:
			entry.mixTime = 0.0
			if previous != null and current.mixTime / current.mixDuration < 0.5:
				entry.previous = previous
				previous = current
			else:
				entry.previous = current
		else:
			track_entry_pool.free_(current)
		if previous != null:
			track_entry_pool.free_(previous)
	tracks[index] = entry
	if entry.listener != null:
		entry.listener.start(index)
	for l in listeners:
		l.start(index)

func set_animation(track_index, animation_name, loop):
	var animation = data.get_skeleton_data().find_animation(animation_name)
	if animation == null:
		push_error("Animation not found: " + animation_name)
		return null
	else:
		return set_animation_by_reference(track_index, animation, loop)

func set_animation_by_reference(track_index, animation, loop):
	var current = expand_to_index(track_index)
	if current != null:
		free_all(current.next)
	#TODO NEXT: use Pool or rewrite
	#var entry = track_entry_pool.obtain()
	var entry = AnimationState.TrackEntry.new()
	entry.animation = animation
	entry.loop = loop
	entry.end_time = animation.get_duration()
	set_current(track_index, entry)
	return entry

func add_animation(track_index, animation_name, loop, delay):
	var animation:Animation_ = data.get_skeleton_data().find_animation(animation_name)
	assert(animation!=null,"Animation not found: "+animation_name)
	return add_animation_by_reference(track_index,animation,loop,delay)

func add_animation_by_reference(track_index, animation, loop, delay):
	var entry = track_entry_pool.obtain()
	entry.animation = animation
	entry.loop = loop
	entry.end_time = animation.get_duration()  # Assumes 'animation' has a method 'get_duration()'.
	
	var last = expand_to_index(track_index)
	if last == null:
		tracks[track_index] = entry
	else:
		while last.next != null:
			last = last.next
		last.next = entry

	if delay <= 0.0:
		if last != null:
			delay += last.end_time - data.get_mix(last.animation, animation)
		else:
			delay = 0.0
	entry.delay = delay
	return entry

func get_current(track_index):
	return null if track_index >= tracks.size() else tracks[track_index]

func add_listener(listener):
	if listener == null:
		push_error("listener cannot be null.")
		return
	listeners.append(listener)

func remove_listener(listener):
	while listener in listeners:
		listeners.erase(listener)

func clear_listeners():
	listeners.clear()

func get_time_scale():
	return time_scale

func set_time_scale(ts):
	time_scale = ts

func get_data():
	return data

func set_data(d):
	data = d

func get_tracks():
	return tracks

func _to_string():
	var buffer = ""
	for entry in tracks:
		if entry != null:
			if buffer != "":
				buffer += ", "
			buffer += entry.to_string()
	return buffer if buffer != "" else "<none>"

# =============================================================================
# Inner class: TrackEntry
# =============================================================================
class TrackEntry:
	var next = null
	var previous = null
	var animation = null
	var loop = false
	var delay = 0.0
	var time = 0.0
	var last_time = -1.0
	var end_time = 0.0
	var time_scale = 1.0
	var mix_time = 0.0
	var mix_duration = 0.0
	var listener = null
	var mix = 1.0

	func _init():
		pass

	func reset():
		next = null
		previous = null
		animation = null
		listener = null
		time_scale = 1.0
		last_time = -1.0
		time = 0.0

	func get_animation():
		return animation

	func set_animation(anim):
		animation = anim

	func get_loop():
		return loop

	func set_loop(value):
		loop = value

	func get_delay():
		return delay

	func set_delay(value):
		delay = value

	func get_time():
		return time

	func set_time(value):
		time = value

	func get_end_time():
		return end_time

	func set_end_time(value):
		end_time = value

	func get_listener():
		return listener

	func set_listener(value):
		listener = value

	func get_last_time():
		return last_time

	func set_last_time(value):
		last_time = value

	func get_mix():
		return mix

	func set_mix(value):
		mix = value

	func get_time_scale():
		return time_scale

	func set_time_scale(value):
		time_scale = value

	func get_next():
		return next

	func set_next(nex):
		next = nex

	func is_complete():
		return time >= end_time

	func _to_string():
		return "<none>" if animation == null else animation.name

# =============================================================================
# Inner class: AnimationStateAdapter
# =============================================================================
class AnimationStateAdapter:
	func _init():
		pass

	func event(track_index, event):
		pass

	func complete(track_index, loop_count):
		pass

	func start(track_index):
		pass

	func end(track_index):
		pass

# =============================================================================
# “Interface” (protocol) for AnimationStateListener.
# =============================================================================
class AnimationStateListener:
	func event(track_index, event):
		pass

	func complete(track_index, loop_count):
		pass

	func start(track_index):
		pass

	func end(track_index):
		pass
