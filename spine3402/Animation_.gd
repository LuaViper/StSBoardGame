class_name Animation_

# The Animation_ class holds a name, an array of timelines, and a duration.
var name: String
var timelines: Array
var duration: float

func _init(name: String, timelines: Array, duration: float) -> void:
	# Validate constructor arguments.
	assert(name != null, "name cannot be null.")
	assert(timelines != null, "timelines cannot be null.")
	self.name = name
	self.timelines = timelines
	self.duration = duration

func get_timelines() -> Array:
	return timelines

func get_duration() -> float:
	return duration

func set_duration(new_duration: float) -> void:
	duration = new_duration

func apply(skeleton:Skeleton, last_time: float, time: float, loop: bool, events: Array) -> void:
	assert(skeleton != null,"skeleton cannot be null.")
	if loop and duration != 0.0:
		time = fmod(time, duration)
		if last_time > 0.0:
			last_time = fmod(last_time, duration)
	# Iterate through each timeline and apply it with full alpha (1.0)
	for i in range(0,timelines.size()):
		timelines.get(i).apply(skeleton, last_time, time, events, 1.0)

func mix(skeleton:Skeleton, last_time: float, time: float, loop: bool, events: Array, alpha: float) -> void:
	assert(skeleton != null,"skeleton cannot be null.")
	if loop and duration != 0.0:
		time = fmod(time, duration)
		if last_time > 0.0:
			last_time = fmod(last_time, duration)
	for i in range(0,timelines.size()):
		timelines.get(i).apply(skeleton, last_time, time, events, 1.0)

func get_name() -> String:
	return name

func _to_string() :
	return name

# Static helper methods for binary and linear searches on arrays of floats.
static func binary_search(values: Array[float], target: float, step: int) -> int:
	var low = 0
	var high = (values.size() / step) - 2
	if high == 0:
		return step
	#TODO: Original uses "high >>> 1", which is a >> bitshift that forces 0 for leftmost bit.
	# The GDScript version will break if high is negative, which should not happen, but...
	var current = high >> 1
	while true:
		if values[(current + 1) * step] <= target:
			low = current + 1
		else:
			high = current
		if low == high:
			return (low + 1) * step
		#TODO: ...and this was originally "low + high >>> 1"
		current = (low + high) >> 1
	#this line should be unreachable
	return 0

static func binary_search_no_step(values: Array[float], target: float) -> int:
	var low = 0
	var high = values.size() - 2
	if high == 0:
		return 1
	var current = high >> 1
	while true:
		if values[current + 1] <= target:
			low = current + 1
		else:
			high = current
		if low == high:
			return low + 1
		current = (low + high) >> 1
	return 0

static func linear_search(values: Array[float], target: float, step: int) -> int:
	var i = 0
	var last = values.size() - step
	while i <= last:
		if values[i] > target:
			return i
		i += step
	return -1

# -------------------------------------------------------------------
# Inner classes (nested within Animation) for timeline types.
# -------------------------------------------------------------------

# Base timeline class that implements curve interpolation.
class CurveTimeline:
	const LINEAR = 0.0
	const STEPPED = 1.0
	const BEZIER = 2.0
	const BEZIER_SIZE = 19

	var curves: Array[float]

	func _init(frame_count: int) -> void:
		assert(frame_count > 0, "frameCount must be > 0: " + str(frame_count))
		curves = []
		curves.resize((frame_count - 1) * BEZIER_SIZE)

	func get_frame_count() -> int:
		return curves.size() / BEZIER_SIZE + 1

	func set_linear(frame_index: int) -> void:
		curves[frame_index * BEZIER_SIZE] = 0.0

	func set_stepped(frame_index: int) -> void:
		curves[frame_index * BEZIER_SIZE] = 1.0

	func get_curve_type(frame_index: int) -> float:
		var index = frame_index * BEZIER_SIZE
		if index == curves.size():
			return LINEAR
		var t = curves[index]
		if t == LINEAR:
			return LINEAR
		else:
			return STEPPED if t == STEPPED else BEZIER

	func set_curve(frame_index: int, cx1: float, cy1: float, cx2: float, cy2: float) -> void:
		var tmpx = (-cx1 * 2.0 + cx2) * 0.03
		var tmpy = (-cy1 * 2.0 + cy2) * 0.03
		var dddfx = ((cx1 - cx2) * 3.0 + 1.0) * 0.006
		var dddfy = ((cy1 - cy2) * 3.0 + 1.0) * 0.006
		var ddfx = tmpx * 2.0 + dddfx
		var ddfy = tmpy * 2.0 + dddfy
		var dfx = cx1 * 0.3 + tmpx + dddfx * 0.16666667
		var dfy = cy1 * 0.3 + tmpy + dddfy * 0.16666667
		var i = frame_index * BEZIER_SIZE
		curves[i] = 2.0
		i += 1
		var x = dfx
		var y = dfy
		var n = i + BEZIER_SIZE - 1
		while i < n:
			curves[i] = x
			curves[i + 1] = y
			dfx += ddfx
			dfy += ddfy
			ddfx += dddfx
			ddfy += dddfy
			x += dfx
			y += dfy
			i += 2

	func get_curve_percent(frame_index: int, percent: float) -> float:
		percent = clamp(percent, 0.0, 1.0)
		var i = frame_index * BEZIER_SIZE
		var t = curves[i]
		if t == LINEAR:
			return percent
		elif t == STEPPED:
			return 0.0
		else:
			i += 1
			var x = 0.0
			var start = i
			var n = i + BEZIER_SIZE - 1
			while i < n:
				x = curves[i]
				if x >= percent:
					var prev_x: float
					var prev_y: float
					if i == start:
						prev_x = 0.0
						prev_y = 0.0
					else:
						prev_x = curves[i - 2]
						prev_y = curves[i - 1]
						
					return prev_y + (curves[i + 1] - prev_y) * (percent - prev_x) / (x - prev_x)
				i += 2
				
			var y = curves[i - 1]
			return y + (1.0 - y) * (percent - x) / (1.0 - x)

#------------------------------------------------------------
# RotateTimeline
#------------------------------------------------------------
class RotateTimeline extends CurveTimeline:
	const ENTRIES = 2
	const PREV_TIME = -2
	const PREV_ROTATION = -1
	const ROTATION = 1

	var bone_index: int = 0
	var frames: Array[float]

	func _init(frame_count: int) -> void:
		super._init(frame_count)
		frames = []
		frames.resize(frame_count << 1)

	func set_bone_index(index: int) -> void:
		assert(index >= 0, "index must be >= 0.")
		bone_index = index

	func get_bone_index() -> int:
		return bone_index

	func get_frames() -> Array[float]:
		return frames

	func set_frame(frame_index: int, time: float, degrees: float) -> void:
		frame_index <<= 1
		frames[frame_index] = time
		frames[frame_index + 1] = degrees

	func apply(skeleton, last_time: float, time: float, events: Array, alpha: float) -> void:
		if time < frames[0]:
			return

		var bone = skeleton.bones.get(bone_index)
		if time >= frames[frames.size() - 2]:
			# Time is after the last frame; use the last frame’s rotation.
			var amount = bone.data.rotation + frames[frames.size() - 1] - bone.rotation
			while amount > 180.0:
				amount -= 360.0
			while amount < -180.0:
				amount += 360.0
			bone.rotation += amount * alpha
		else:
			var frame = Animation_.binary_search(frames, time, 2)
			var prev_rotation = frames[frame - 1]
			var frame_time = frames[frame]
			var percent = get_curve_percent((frame >> 1) - 1, 1.0 - (time - frame_time) / (frames[frame - 2] - frame_time))
			var amount = frames[frame + 1] - prev_rotation
			while amount > 180.0:
				amount -= 360.0
			while amount < -180.0:
				amount += 360.0
			amount = bone.data.rotation + prev_rotation + amount * percent - bone.rotation
			while amount > 180.0:
				amount -= 360.0
			while amount < -180.0:
				amount += 360.0
			bone.rotation += amount * alpha

#------------------------------------------------------------
# TranslateTimeline
#------------------------------------------------------------
class TranslateTimeline extends CurveTimeline:
	const ENTRIES = 3
	const PREV_TIME = -3
	const PREV_X = -2
	const PREV_Y = -1
	const X = 1
	const Y = 2
	var bone_index: int = 0
	var frames: Array[float]

	func _init(frame_count: int) -> void:
		super._init(frame_count)
		frames = []
		frames.resize(frame_count * 3)

	func set_bone_index(index: int) -> void:
		assert(index >= 0, "index must be >= 0.")
		bone_index = index

	func get_bone_index() -> int:
		return bone_index

	func get_frames() -> Array[float]:
		return frames

	func set_frame(frame_index: int, time: float, x: float, y: float) -> void:
		var index = frame_index * 3
		frames[index] = time
		frames[index + 1] = x
		frames[index + 2] = y

	func apply(skeleton, last_time: float, time: float, events: Array, alpha: float) -> void:
		if time < frames[0]:
			return

		var bone = skeleton.bones.get(bone_index)
		if time >= frames[frames.size() - 3]:
			bone.x += (bone.data.x + frames[frames.size() - 2] - bone.x) * alpha
			bone.y += (bone.data.y + frames[frames.size() - 1] - bone.y) * alpha
		else:
			var frame = Animation_.binary_search(frames, time, 3)
			var prev_x = frames[frame - 2]
			var prev_y = frames[frame - 1]
			var frame_time = frames[frame]
			var percent = get_curve_percent(int(frame / 3) - 1, 1.0 - (time - frame_time) / (frames[frame - 3] - frame_time))
			bone.x += (bone.data.x + prev_x + (frames[frame + 1] - prev_x) * percent - bone.x) * alpha
			bone.y += (bone.data.y + prev_y + (frames[frame + 2] - prev_y) * percent - bone.y) * alpha

#------------------------------------------------------------
# ScaleTimeline 
#------------------------------------------------------------
class ScaleTimeline extends TranslateTimeline:
	func _init(frame_count: int) -> void:
		super._init(frame_count)

	func apply(skeleton, last_time: float, time: float, events: Array, alpha: float) -> void:
		if time < frames[0]:
			return

		var bone:Bone = skeleton.bones.get(bone_index)
		if time >= frames[frames.size() - 3]:
			bone.scale_x += (bone.data.scale_x * frames[frames.size() - 2] - bone.scale_x) * alpha
			bone.scale_y += (bone.data.scale_y * frames[frames.size() - 1] - bone.scale_y) * alpha
		else:
			var frame:int = Animation_.binary_search(frames, time, 3)
			var prev_x:float = frames[frame - 2]
			var prev_y:float = frames[frame - 1]
			var frame_time:float = frames[frame]
			var percent:float = get_curve_percent(int(frame / 3) - 1, 1.0 - (time - frame_time) / (frames[frame - 3] - frame_time))
			bone.scale_x += (bone.data.scale_x * (prev_x + (frames[frame + 1] - prev_x) * percent) - bone.scale_x) * alpha
			bone.scale_y += (bone.data.scale_y * (prev_y + (frames[frame + 2] - prev_y) * percent) - bone.scale_y) * alpha

#------------------------------------------------------------
# ShearTimeline 
#------------------------------------------------------------
class ShearTimeline extends TranslateTimeline:

	func _init(frame_count: int) -> void:
		super._init(frame_count)

	func apply(skeleton, last_time: float, time: float, events: Array, alpha: float) -> void:
		if time < frames[0]:
			return

		var bone = skeleton.bones.get(bone_index)
		if time >= frames[frames.size() - 3]:
			bone.shear_x += (bone.data.shear_x + frames[frames.size() - 2] - bone.shear_x) * alpha
			bone.shear_y += (bone.data.shear_y + frames[frames.size() - 1] - bone.shear_y) * alpha
		else:
			var frame = Animation_.binary_search(frames, time, 3)
			var prev_x = frames[frame - 2]
			var prev_y = frames[frame - 1]
			var frame_time = frames[frame]
			var percent = get_curve_percent(int(frame / 3) - 1, 1.0 - (time - frame_time) / (frames[frame - 3] - frame_time))
			bone.shear_x += (bone.data.shear_x + prev_x + (frames[frame + 1] - prev_x) * percent - bone.shear_x) * alpha
			bone.shear_y += (bone.data.shear_y + prev_y + (frames[frame + 2] - prev_y) * percent - bone.shear_y) * alpha

class ColorTimeline extends CurveTimeline:
	const ENTRIES:int = 5
	const PREV_TIME:int = -5
	const PREV_R:int = -4
	const PREV_G:int = -3
	const PREV_B:int = -2
	const PREV_A:int = -1
	const R:int = 1
	const G:int = 2
	const B:int = 3
	const A:int = 4	
	var slot_index:int = 0
	var frames:Array[float] = []
	
	func _init(frame_count: int):
		super._init(frame_count)
		frames.resize(frame_count * ENTRIES)
	
	func set_slot_index(index: int):
		assert(index>=0,"index must be >= 0.")
		slot_index = index
	
	func get_slot_index() -> int:
		return slot_index
	
	func get_frames() -> Array[float]:
		return frames
	
	func set_frame(frame_index: int, time: float, r: float, g: float, b: float, a: float):
		frame_index *= ENTRIES
		frames[frame_index] = time
		frames[frame_index + R] = r
		frames[frame_index + G] = g
		frames[frame_index + B] = b
		frames[frame_index + A] = a
	
	func apply(skeleton, last_time: float, time: float, events, alpha: float):
		if time < frames[0]:
			return
		var r: float
		var g: float
		var b: float
		var a: float
		if time >= frames[frames.size() + PREV_TIME]:
			var i = frames.size()
			r = frames[i + PREV_R]
			g = frames[i + PREV_G]
			b = frames[i + PREV_B]
			a = frames[i + PREV_A]
		else:
			var frame = Animation_.binary_search(frames, time, ENTRIES)
			r = frames[frame + PREV_R]
			g = frames[frame + PREV_G]
			b = frames[frame + PREV_B]
			a = frames[frame + PREV_A]
			var frame_time = frames[frame]
			var percent = get_curve_percent(frame / ENTRIES - 1, 1.0 - (time - frame_time) / (frames[frame + PREV_TIME] - frame_time))
			r += (frames[frame + R] - r) * percent
			g += (frames[frame + G] - g) * percent
			b += (frames[frame + B] - b) * percent
			a += (frames[frame + A] - a) * percent
		var color = skeleton.slots.get(slot_index).color
		if alpha < 1.0:
			color.add((r - color.r) * alpha, (g - color.g) * alpha, (b - color.b) * alpha, (a - color.a) * alpha)
			color.r += r - color.r * alpha
			color.g += g - color.g * alpha
			color.b += b - color.b * alpha
			color.a += a - color.a * alpha
		else:
			color.r = r
			color.g = g
			color.b = b
			color.a = a
		#turns out color is a raw value, not a reference, so we have to manually assign it back
		skeleton.slots.get(slot_index).color = color

class AttachmentTimeline extends Timeline:
	var slot_index:int
	var frames:Array[float] = []
	var attachment_names:Array[String] = []
	
	func _init(frame_count: int):
		#do not call super._init
		frames=[]
		frames.resize(frame_count)
		attachment_names=[]
		attachment_names.resize(frame_count)
	
	func get_frame_count() -> int:
		return frames.size()
	
	func set_slot_index(index: int):
		assert(index>=0,"index must be >= 0.")
		slot_index = index
	
	func get_slot_index() -> int:
		return slot_index
	
	func get_frames() -> Array:
		return frames
	
	func get_attachment_names() -> Array:
		return attachment_names
	
	func set_frame(frame_index: int, time: float, attachment_name: String):
		frames[frame_index] = time
		attachment_names[frame_index] = attachment_name
	
	func apply(skeleton, last_time: float, time: float, events:Array, alpha: float):
		if time < frames[0]:
			return
		var frame_index: int
		if time >= frames[frames.size() - 1]:
			frame_index = frames.size() - 1
		else:
			frame_index = Animation_.binary_search(frames, time, 1) - 1
		var attachment_name = attachment_names[frame_index]
		skeleton.slots.get(slot_index).set_attachment(null if attachment_name == null else skeleton.get_attachment(slot_index, attachment_name))

#TODO: this is roughly where we got sloppy at checking Microsoft's work
class EventTimeline extends Timeline:
	var frames: Array[float] = []
	var events: Array[Event] = []
	
	func _init(frame_count: int) -> void:
		#do not call super._init
		frames=[]
		frames.resize(frame_count)
		events=[]
		events.resize(frame_count)
	
	func get_frame_count() -> int:
		return frames.size()
	
	func get_frames() -> Array[float]:
		return frames
	
	func get_events() -> Array[Event]:
		return events
	
	func set_frame(frame_index: int, event:Event) -> void:
		frames[frame_index] = event.time
		events[frame_index] = event
	
	func apply(skeleton, last_time: float, time: float, fired_events:Array, alpha: float) -> void:
		if fired_events:
			var frame_count = frames.size()
			if last_time > time:
				#TODO: make sure this is really Integer.MAX_INT
				apply(skeleton, last_time, 2147483647.0, fired_events, alpha)
				last_time = -1.0
			elif last_time >= frames[frame_count - 1]:
				return
			
			if time >= frames[0]:
				var frame: int
				if last_time < frames[0]:
					frame = 0
				else:
					frame = Animation_.binary_search_no_step(frames, last_time)
					var frame_time = frames[frame]
					# Back up over duplicate times.
					while frame > 0 and frames[frame - 1] == frame_time:
						frame -= 1
				
				while frame < frame_count and time >= frames[frame]:
					fired_events.append(events[frame])
					frame += 1

class DrawOrderTimeline extends Timeline:
	var frames:Array[float] = []	
	var draw_orders:Array = []	# Array of int[]
	
	func _init(frame_count: int) -> void:
		#do not call super._init
		frames=[]
		frames.resize(frame_count)
		draw_orders=[]
		draw_orders.resize(frame_count)
	
	func get_frame_count() -> int:
		return frames.size()
	
	func get_frames() -> Array[float]:
		return frames
	
	func get_draw_orders() -> Array:
		return draw_orders
	
	func set_frame(frame_index: int, time: float, draw_order: Array) -> void:
		frames[frame_index] = time
		draw_orders[frame_index] = draw_order
	
	func apply(skeleton, last_time: float, time: float, fired_events, alpha: float) -> void:
		if time < frames[0]:
			return
		
		var frame: int
		if time >= frames[frames.size() - 1]:
			frame = frames.size() - 1
		else:
			frame = Animation_.binary_search_no_step(frames, time) - 1
		
		var draw_order = skeleton.drawOrder
		var slots = skeleton.slots
		var order_indices = draw_orders[frame]
		if order_indices == null:
			#substitution for Java's System.arrayCopy
			#TODO: this is currently a shallow copy; does that break things?
			for i in range(slots.size()):
				draw_order[i] = slots[i]
		else:
			# Apply the custom draw order.
			for i in range(order_indices.size()):
				draw_order.set(i, slots.items[order_indices[i]])

class DeformTimeline extends CurveTimeline:
	var frames:Array[float] = []		   
	var frame_vertices:Array = []   # Array of float[]
	var slot_index:int = 0
	var attachment:VertexAttachment = null
	
	func _init(frame_count: int) -> void:
		super._init(frame_count)
		frames=[]
		frames.resize(frame_count)
		frame_vertices=[]
		frame_vertices.resize(frame_count)
	
	func set_slot_index(index: int) -> void:
		assert(index>=0,"index must be >= 0.")
		slot_index = index
	
	func get_slot_index() -> int:
		return slot_index
	
	func set_attachment(att) -> void:
		attachment = att
	
	func get_attachment():
		return attachment
	
	func get_frames() -> Array:
		return frames
	
	func get_vertices() -> Array:
		return frame_vertices
	
	func set_frame(frame_index: int, time: float, vertices: Array) -> void:
		frames[frame_index] = time
		frame_vertices[frame_index] = vertices
	
	func apply(skeleton, last_time: float, time: float, fired_events: Array, alpha: float) -> void:
		var slot:Slot = skeleton.slots.get(slot_index)
		var slot_attachment = slot.attachment
		if slot_attachment is VertexAttachment and (slot_attachment as VertexAttachment).apply_deform(attachment):
			if time < frames[0]:
				return
			var vertex_count:int = frame_vertices[0].size()
			var vertices_array:Array = slot.get_attachment_vertices()
			if vertices_array.size() != vertex_count:
				alpha = 1.0
			#TODO: original Java version may or may not have performed an array copy here
			vertices_array.resize(vertex_count)
			var vertices = vertices_array						
			
			if time >= frames[frames.size() - 1]:
				var last_vertices = frame_vertices[frames.size() - 1]
				if alpha < 1.0:
					for i in range(vertex_count):
						vertices[i] += (last_vertices[i] - vertices[i]) * alpha
				else:
					# Copy last_vertices completely into vertices.
					# (Java: System.arraycopy)
					for i in range(vertex_count):
						vertices[i] = last_vertices[i]
			else:
				var frame = Animation_.binary_search_no_step(frames, time)
				var prev_vertices = frame_vertices[frame - 1]
				var next_vertices = frame_vertices[frame]
				var frame_time = frames[frame]
				var percent = get_curve_percent(frame - 1, 1.0 - (time - frame_time) / (frames[frame - 1] - frame_time))				
				if alpha < 1.0:
					for i in range(vertex_count):
						var prev = prev_vertices[i]
						vertices[i] += (prev + (next_vertices[i] - prev) * percent - vertices[i]) * alpha
				else:
					for i in range(vertex_count):
						var prev = prev_vertices[i]
						vertices[i] = prev + (next_vertices[i] - prev) * percent

class IkConstraintTimeline extends CurveTimeline:
	const ENTRIES = 3
	const PREV_TIME = -3
	const PREV_MIX = -2
	const PREV_BEND_DIRECTION = -1
	const MIX = 1
	const BEND_DIRECTION = 2

	var ik_constraint_index: int = 0
	var frames: Array = []  # Float array holding time, mix, and bend direction.

	func _init(frame_count: int) -> void:
		super._init(frame_count)
		frames=[]
		frames.resize(frame_count * ENTRIES)

	func set_ik_constraint_index(index: int) -> void:
		if index < 0:
			push_error("index must be >= 0.")
		else:
			ik_constraint_index = index

	func get_ik_constraint_index() -> int:
		return ik_constraint_index

	func get_frames() -> Array:
		return frames

	func set_frame(frame_index: int, time: float, mix: float, bend_direction: int) -> void:
		frame_index *= ENTRIES
		frames[frame_index] = time
		frames[frame_index + 1] = mix
		frames[frame_index + 2] = float(bend_direction)

	func apply(skeleton, last_time: float, time: float, events, alpha: float) -> void:
		if time < frames[0]:
			return
		var constraint = skeleton.ik_constraints[ik_constraint_index]
		if time >= frames[frames.size() - ENTRIES]:
			var i = frames.size()
			constraint.mix += (frames[i - 2] - constraint.mix) * alpha
			constraint.bend_direction = int(frames[i - 1])
		else:
			var frame = Animation_.binary_search(frames, time, ENTRIES)
			var mix_val = frames[frame + PREV_MIX]
			var frame_time = frames[frame]
			var percent = get_curve_percent(frame / ENTRIES - 1, 1.0 - (time - frame_time) / (frames[frame + PREV_TIME] - frame_time))
			constraint.mix += (mix_val + (frames[frame + MIX] - mix_val) * percent - constraint.mix) * alpha
			constraint.bend_direction = int(frames[frame + PREV_BEND_DIRECTION])

class TransformConstraintTimeline extends CurveTimeline:
	const ENTRIES = 5
	const PREV_TIME = -5
	const PREV_ROTATE = -4
	const PREV_TRANSLATE = -3
	const PREV_SCALE = -2
	const PREV_SHEAR = -1
	const ROTATE = 1
	const TRANSLATE = 2
	const SCALE = 3
	const SHEAR = 4

	var transform_constraint_index: int = 0
	var frames: Array = []  # Holds time, rotateMix, translateMix, scaleMix, and shearMix.

	func _init(frame_count: int) -> void:
		super._init(frame_count)
		frames.resize(frame_count * ENTRIES)

	func set_transform_constraint_index(index: int) -> void:
		if index < 0:
			push_error("index must be >= 0.")
		else:
			transform_constraint_index = index

	func get_transform_constraint_index() -> int:
		return transform_constraint_index

	func get_frames() -> Array:
		return frames

	func set_frame(frame_index: int, time: float, rotate_mix: float, translate_mix: float, scale_mix: float, shear_mix: float) -> void:
		frame_index *= ENTRIES
		frames[frame_index] = time
		frames[frame_index + 1] = rotate_mix
		frames[frame_index + 2] = translate_mix
		frames[frame_index + 3] = scale_mix
		frames[frame_index + 4] = shear_mix

	func apply(skeleton, last_time: float, time: float, events, alpha: float) -> void:
		if time < frames[0]:
			return
		var constraint = skeleton.transformConstraints[transform_constraint_index]
		if time >= frames[frames.size() - ENTRIES]:
			var i = frames.size()
			constraint.rotateMix += (frames[i - 4] - constraint.rotateMix) * alpha
			constraint.translateMix += (frames[i - 3] - constraint.translateMix) * alpha
			constraint.scaleMix += (frames[i - 2] - constraint.scaleMix) * alpha
			constraint.shearMix += (frames[i - 1] - constraint.shearMix) * alpha
		else:
			var frame = Animation_.binary_search(frames, time, ENTRIES)
			var frame_time = frames[frame]
			var percent = get_curve_percent(frame / ENTRIES - 1, 1.0 - (time - frame_time) / (frames[frame + PREV_TIME] - frame_time))
			var rotate_val = frames[frame + PREV_ROTATE]
			var translate_val = frames[frame + PREV_TRANSLATE]
			var scale_val = frames[frame + PREV_SCALE]
			var shear_val = frames[frame + PREV_SHEAR]
			constraint.rotateMix += (rotate_val + (frames[frame + ROTATE] - rotate_val) * percent - constraint.rotateMix) * alpha
			constraint.translateMix += (translate_val + (frames[frame + TRANSLATE] - translate_val) * percent - constraint.translateMix) * alpha
			constraint.scaleMix += (scale_val + (frames[frame + SCALE] - scale_val) * percent - constraint.scaleMix) * alpha
			constraint.shearMix += (shear_val + (frames[frame + SHEAR] - shear_val) * percent - constraint.shearMix) * alpha

class PathConstraintPositionTimeline extends CurveTimeline:
	const ENTRIES = 2
	const PREV_TIME = -2
	const PREV_VALUE = -1
	const VALUE = 1

	var path_constraint_index: int = 0
	var frames: Array = []  # Each frame holds time and a value.

	func _init(frame_count: int) -> void:
		super._init(frame_count)
		frames.resize(frame_count * ENTRIES)

	func set_path_constraint_index(index: int) -> void:
		if index < 0:
			#TODO: replace push_errors with asserts
			push_error("index must be >= 0.")
		else:
			path_constraint_index = index

	func get_path_constraint_index() -> int:
		return path_constraint_index

	func get_frames() -> Array:
		return frames

	func set_frame(frame_index: int, time: float, value: float) -> void:
		frame_index *= ENTRIES
		frames[frame_index] = time
		frames[frame_index + 1] = value

	func apply(skeleton, last_time: float, time: float, events, alpha: float) -> void:
		if time < frames[0]:
			return
		var constraint = skeleton.pathConstraints[path_constraint_index]
		if time >= frames[frames.size() - ENTRIES]:
			var i = frames.size()
			constraint.position += (frames[i - 1] - constraint.position) * alpha
		else:
			var frame = Animation_.binary_search(frames, time, ENTRIES)
			var position_val = frames[frame + PREV_VALUE]
			var frame_time = frames[frame]
			var percent = get_curve_percent(frame / ENTRIES - 1, 1.0 - (time - frame_time) / (frames[frame + PREV_TIME] - frame_time))
			constraint.position += (position_val + (frames[frame + VALUE] - position_val) * percent - constraint.position) * alpha

# PathConstraintSpacingTimeline.gd
class PathConstraintSpacingTimeline extends PathConstraintPositionTimeline:

	func _init(frame_count: int) -> void:
		super._init(frame_count)  # Inherit initialization from the parent.

	func apply(skeleton, last_time: float, time: float, events, alpha: float) -> void:
		if time < frames[0]:
			return
		var constraint = skeleton.pathConstraints[path_constraint_index]
		if time >= frames[frames.size() - ENTRIES]:
			var i = frames.size()
			constraint.spacing += (frames[i - 1] - constraint.spacing) * alpha
		else:
			var frame = Animation_.binary_search(frames, time, ENTRIES)
			var spacing_val = frames[frame + PREV_VALUE]
			var frame_time = frames[frame]
			var percent = get_curve_percent(frame / ENTRIES - 1, 1.0 - (time - frame_time) / (frames[frame + PREV_TIME] - frame_time))
			constraint.spacing += (spacing_val + (frames[frame + VALUE] - spacing_val) * percent - constraint.spacing) * alpha

class PathConstraintMixTimeline extends CurveTimeline:
	const ENTRIES = 3
	const PREV_TIME = -3
	const PREV_ROTATE = -2
	const PREV_TRANSLATE = -1
	const ROTATE = 1
	const TRANSLATE = 2

	var path_constraint_index: int = 0
	var frames: Array = []  # Floats array of size frame_count * ENTRIES

	func _init(frame_count: int) -> void:
		super._init(frame_count)
		frames.resize(frame_count * ENTRIES)

	func set_path_constraint_index(index: int) -> void:
		if index < 0:
			push_error("index must be >= 0.")
		else:
			path_constraint_index = index

	func get_path_constraint_index() -> int:
		return path_constraint_index

	func get_frames() -> Array:
		return frames

	func set_frame(frame_index: int, time: float, rotate_mix: float, translate_mix: float) -> void:
		frame_index *= ENTRIES
		frames[frame_index] = time
		frames[frame_index + 1] = rotate_mix
		frames[frame_index + 2] = translate_mix

	func apply(skeleton, last_time: float, time: float, events, alpha: float) -> void:
		if time < frames[0]:
			return

		var constraint = skeleton.pathConstraints[path_constraint_index]
		if time >= frames[frames.size() - ENTRIES]:
			var i = frames.size()
			constraint.rotateMix += (frames[i - 2] - constraint.rotateMix) * alpha
			constraint.translateMix += (frames[i - 1] - constraint.translateMix) * alpha
		else:
			var frame = Animation_.binary_search(frames, time, ENTRIES)
			var rotate_val = frames[frame + PREV_ROTATE]
			var translate_val = frames[frame + PREV_TRANSLATE]
			var frame_time = frames[frame]
			var percent = get_curve_percent(frame / ENTRIES - 1, 1.0 - (time - frame_time) / (frames[frame + PREV_TIME] - frame_time))
			constraint.rotateMix += (rotate_val + (frames[frame + ROTATE] - rotate_val) * percent - constraint.rotateMix) * alpha
			constraint.translateMix += (translate_val + (frames[frame + TRANSLATE] - translate_val) * percent - constraint.translateMix) * alpha


class Timeline:
	func apply(var1:Skeleton, var2:float, var3:float, var4:Array, var5:float):
		pass
