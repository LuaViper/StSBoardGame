class_name SkeletonBounds

var min_x: float
var min_y: float
var max_x: float
var max_y: float
var bounding_boxes: Array = []
var polygons: Array = []
var polygon_pool: Array = []

func _init():
	pass

func update(skeleton: Skeleton, update_aabb: bool):
	if skeleton == null:
		push_error("skeleton cannot be null.")
		return
	
	bounding_boxes.clear()
	polygons.clear()
	
	for slot in skeleton.slots:
		var attachment = slot.attachment
		if attachment is BoundingBoxAttachment:
			bounding_boxes.append(attachment)
			var polygon = []
			polygons.append(polygon)
			polygon.resize(attachment.get_world_vertices_length())
			attachment.compute_world_vertices(slot, polygon)

	if update_aabb:
		aabb_compute()

func aabb_compute():
	min_x = INF
	min_y = INF
	max_x = -INF
	max_y = -INF

	for polygon in polygons:
		for i in range(0, len(polygon), 2):
			var x = polygon[i]
			var y = polygon[i + 1]
			min_x = min(min_x, x)
			min_y = min(min_y, y)
			max_x = max(max_x, x)
			max_y = max(max_y, y)

func aabb_contains_point(x: float, y: float) -> bool:
	return x >= min_x and x <= max_x and y >= min_y and y <= max_y

func aabb_intersects_segment(x1: float, y1: float, x2: float, y2: float) -> bool:
	var min_x = self.min_x
	var min_y = self.min_y
	var max_x = self.max_x
	var max_y = self.max_y

	if ((!(x1 <= min_x) or !(x2 <= min_x)) and 
		(!(y1 <= min_y) or !(y2 <= min_y)) and 
		(!(x1 >= max_x) or !(x2 >= max_x)) and 
		(!(y1 >= max_y) or !(y2 >= max_y))):

		var m = (y2 - y1) / (x2 - x1)
		var y = m * (min_x - x1) + y1
		if y > min_y and y < max_y:
			return true
		else:
			y = m * (max_x - x1) + y1
			if y > min_y and y < max_y:
				return true
			else:
				var x = (min_y - y1) / m + x1
				if x > min_x and x < max_x:
					return true
				else:
					x = (max_y - y1) / m + x1
					return x > min_x and x < max_x
	else:
		return false


func aabb_intersects_skeleton(bounds: SkeletonBounds) -> bool:
	return min_x < bounds.max_x and max_x > bounds.min_x and min_y < bounds.max_y and max_y > bounds.min_y

func contains_point(x: float, y: float) -> BoundingBoxAttachment:
	for i in range(len(polygons)):
		if contains_point_polygon(polygons[i], x, y):
			return bounding_boxes[i]
	return null

func contains_point_polygon(polygon: Array, x: float, y: float) -> bool:
	var inside = false
	var prev_index = len(polygon) - 2
	for ii in range(0, len(polygon), 2):
		var vertex_y = polygon[ii + 1]
		var prev_y = polygon[prev_index + 1]
		if (vertex_y < y and prev_y >= y) or (prev_y < y and vertex_y >= y):
			var vertex_x = polygon[ii]
			if vertex_x + (y - vertex_y) / (prev_y - vertex_y) * (polygon[prev_index] - vertex_x) < x:
				inside = !inside
		prev_index = ii
	return inside

func intersects_segment(x1: float, y1: float, x2: float, y2: float) -> BoundingBoxAttachment:
	for i in range(len(polygons)):
		if intersects_segment_polygon(polygons[i], x1, y1, x2, y2):
			return bounding_boxes[i]
	return null

func intersects_segment_polygon(polygon: Array, x1: float, y1: float, x2: float, y2: float) -> bool:
	var vertices = polygon
	var nn = len(vertices)
	var width12 = x1 - x2
	var height12 = y1 - y2
	var det1 = x1 * y2 - y1 * x2
	var x3 = vertices[nn - 2]
	var y3 = vertices[nn - 1]

	for ii in range(0, nn, 2):
		var x4 = vertices[ii]
		var y4 = vertices[ii + 1]
		var det2 = x3 * y4 - y3 * x4
		var width34 = x3 - x4
		var height34 = y3 - y4
		var det3 = width12 * height34 - height12 * width34
		var x = (det1 * width34 - width12 * det2) / det3
		if (x >= x3 and x <= x4 or x >= x4 and x <= x3) and (x >= x1 and x <= x2 or x >= x2 and x <= x1):
			var y = (det1 * height34 - height12 * det2) / det3
			if (y >= y3 and y <= y4 or y >= y4 and y <= y3) and (y >= y1 and y <= y2 or y >= y2 and y <= y1):
				return true
		x3 = x4
		y3 = y4

	return false

func get_min_x() -> float:
	return min_x

func get_min_y() -> float:
	return min_y

func get_max_x() -> float:
	return max_x

func get_max_y() -> float:
	return max_y

func get_width() -> float:
	return max_x - min_x

func get_height() -> float:
	return max_y - min_y

func get_bounding_boxes() -> Array:
	return bounding_boxes

func get_polygons() -> Array:
	return polygons

func get_polygon(bounding_box: BoundingBoxAttachment):
	if bounding_box == null:
		push_error("boundingBox cannot be null.")
		return null
	var index = bounding_boxes.find(bounding_box)
	return null if index == -1 else polygons[index]
