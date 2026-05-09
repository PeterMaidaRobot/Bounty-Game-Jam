class_name Person extends Node2D


@export_group("Body")
@export var body_width : int = 25
@export var body_height : int = 50
@export var body_color : Color = Color.SADDLE_BROWN

@export_group("Eyebrow")
@export var eyebrow_width : int = 17
@export var eyebrow_height : int = 7
@export var eyebrow_spacing : int = 10
@export var eyebrow_y_offset : int = -19
@export var eyebrow_rotation : int = 20
@export var eyebrow_color : Color = Color.DARK_GREEN

@export_group("Eye")
@export var eye_radius : int = 3
@export var eye_spacing : int = 10
@export var eye_y_offset : int = -7
@export var eye_color : Color = Color.BLACK

@export_group("Moustache")
@export var moustache_radius : int = 8
@export var moustache_endpoint_ratio : float = 2
@export var moustache_bridge_ratio : float = 1.5
@export var moustache_height_ratio : float = 0.5
@export var moustache_color : Color = Color.DARK_GREEN

@export_group("Head")
@export var head_height : int = 20
@export var head_width : int = 18
@export var head_color : Color = Color.YELLOW

@export_group("")


#var player_pos = Vector2(0, 0)

const my_scene : PackedScene = preload("res://person.tscn")



static func constructor(pos : Vector2) -> Person:
	var person = my_scene.instantiate()
	#person.player_pos = pos
	person.position = pos
	return person



#func _ready():
	#
	#var my_node = Node2D.new()
	#
	#my_node.position = Vector2(200, 150)
	#
	#add_child(my_node)
	#
	#var label = Label.new()
	#label.text = "hello from node 2d!"
	#my_node.add_child(label)




func _draw_body(position : Vector2):
	draw_rect(Rect2(position.x - (body_width/2), position.y, body_width, body_height), body_color)


func _draw_head(position : Vector2):
	draw_ellipse(position, head_width, head_height, head_color)
	
	
	
func float_array_to_Vector2Array(coords : Array) -> PackedVector2Array:
	# Convert the array of floats into a PackedVector2Array.
	var array : PackedVector2Array = []
	for coord in coords:
		array.append(Vector2(coord[0], coord[1]))
	return array
	
	
	
#func get_triangle_points(position : Vector2, size): # size is kind of a radius? this triangle isn't equalatiural
	## triangle is centered on position
	#var coords = [
		#[position.x - size * 2, position.y + size * 2], # left point
		#[position.x + size * 2, position.y + size * 2], # right point
		#[position.x, position.y - size]  # top point
	#]
	#var head = float_array_to_Vector2Array(coords)
	#return head
	
	
func _draw_moustache(position : Vector2):
	#var head = get_triangle_points(position, moustache_radius)
	var coords = [
		[position.x - moustache_radius * moustache_endpoint_ratio, position.y + moustache_radius * moustache_endpoint_ratio], # left point
		[position.x + moustache_radius * moustache_endpoint_ratio, position.y + moustache_radius * moustache_endpoint_ratio], # right point
		[position.x + moustache_radius * moustache_bridge_ratio, position.y], # top-right point
		[position.x, position.y - moustache_radius * moustache_height_ratio],  # top point
		[position.x - moustache_radius * moustache_bridge_ratio, position.y], # top-left point
	]
	var head = float_array_to_Vector2Array(coords)
	draw_polygon(head, [ moustache_color ])


func _draw_eyes(position : Vector2):
	draw_circle(position + Vector2(eye_spacing * -1, eye_y_offset), eye_radius, eye_color)
	draw_circle(position + Vector2(eye_spacing, eye_y_offset), eye_radius, eye_color)



func draw_rotated_rect(rect : Rect2, degrees : int, pivot : Vector2): # it's not a pivot it's kinda the offset?
	#var rect = Rect2(Vector2(0, 0), Vector2(100, 50))
	var rotation_angle = deg_to_rad(degrees) # 30 degrees

	# Create a transform with rotation
	var transform_x = Transform2D(rotation_angle, Vector2(0, 0))

	## Convert Rect2 to polygon points
	var points = [
		Vector2(0, 0),
		Vector2(rect.size.x, 0),
		Vector2(rect.size.x, rect.size.y),
		Vector2(0, rect.size.y)
	]
#
	## Apply rotation transform to each point
	for i in range(points.size()):
		points[i] = transform_x.basis_xform(points[i])
		points[i] += pivot + Vector2(0, -sin(rotation_angle)*eyebrow_rotation/2)
	

	# Draw rotated polygon
	draw_polygon(points, [ eyebrow_color ])
	
	
func _draw_eyebrows(position : Vector2):
	#draw_rect(Rect2(position.x - eyebrow_spacing - (eyebrow_width/2), position.y + eyebrow_y_offset, eyebrow_width, eyebrow_height), Color.DARK_GREEN)
	#draw_rect(Rect2(position.x + eyebrow_spacing - (eyebrow_width/2), position.y + eyebrow_y_offset, eyebrow_width, eyebrow_height), Color.DARK_GREEN)
	var pivot : Vector2 = Vector2(position.x - eyebrow_spacing - (eyebrow_width/2), position.y + eyebrow_y_offset)
	#draw_circle(pivot, 5, Color.RED)
	#for i in range(0,91):
		#draw_rotated_rect(Rect2(0, 0, eyebrow_width, eyebrow_height), eyebrow_rotation + i, pivot)
	draw_rotated_rect(Rect2(0, 0, eyebrow_width, eyebrow_height), eyebrow_rotation, pivot)
	pivot = Vector2(position.x + eyebrow_spacing - (eyebrow_width/2), position.y + eyebrow_y_offset)
	draw_rotated_rect(Rect2(0, 0, eyebrow_width, eyebrow_height), eyebrow_rotation * -1, pivot)
		#draw_rotated_rect(Rect2(position.x - eyebrow_spacing - (eyebrow_width/2), position.y + eyebrow_y_offset, eyebrow_width, eyebrow_height), eyebrow_rotation + i, pivot)
	#var default_rect = Rect2(0, 0, eyebrow_width, eyebrow_height)
	#var rotation_angle = deg_to_rad(-90) # 30 degrees
	#var transform_x = Transform2D(rotation_angle, Vector2(0, 0))
	#var new_rect : Rect2 = default_rect * transform_x # ORDER HERE MATTERS !!!!!
	#new_rect.position.x += position.x - eyebrow_spacing - (eyebrow_width/2)
	#new_rect.position.y += position.y + eyebrow_y_offset
	#var points = [
		#new_rect.position,
		#new_rect.position + Vector2(new_rect.size.x, 0),
		#new_rect.position + new_rect.size,
		#new_rect.position + Vector2(0, new_rect.size.y)
	#]	
	#draw_polygon(points, [ Color.DARK_GREEN ])
	
	#default_rect = Rect2(0, 0, eyebrow_width, eyebrow_height)
	#rotation_angle = deg_to_rad(0) # 30 degrees
	#transform_x = Transform2D(rotation_angle, Vector2(0, 0))
	#new_rect = default_rect * transform_x # ORDER HERE MATTERS !!!!!
	#new_rect.position.x += position.x - eyebrow_spacing - (eyebrow_width/2)
	#new_rect.position.y += position.y + eyebrow_y_offset
	#draw_polygon(new_rect, Color.DARK_GREEN)


func _draw_person(position : Vector2):
	_draw_body(position)
	_draw_head(position)
	_draw_moustache(position + Vector2(0, 2))
	_draw_eyes(position)
	_draw_eyebrows(position)


func _draw():
	_draw_person(position)
	#draw_circle(position, 2, Color.GREEN)
	
func _process(delta):
	queue_redraw()
	
