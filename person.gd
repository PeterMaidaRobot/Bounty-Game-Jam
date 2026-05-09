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


signal person_clicked(person)


var target : Vector2
var speed : int = 30 # 10 is a casual speed
var full_name : String = "Bob Smith"
var bounty : int = 0 # if the bounty is zero, they aren't a criminal
var caught : bool = false

var has_eyebrows = true
var has_moustache = true


const my_scene : PackedScene = preload("res://person.tscn")

var draw_enabled = true

var head_color_idx : int = 0
var hair_color_idx : int = 0
var body_color_idx : int = 0
var eyes_color_idx : int = 0


const EYE_COLORS = [
	Color.WHITE,
	Color.RED,
	Color.DARK_BLUE,
	Color.BLACK
]

const HEAD_COLORS = [
	Color.YELLOW,
	Color.ROSY_BROWN,
	Color.SANDY_BROWN,
	Color.SADDLE_BROWN,
	Color.BLANCHED_ALMOND
]

const HAIR_COLORS = [
	Color.WHITE,
	Color.GRAY,
	Color.INDIAN_RED,
	Color.YELLOW,
	Color.SADDLE_BROWN,
	Color.BLACK,
	Color.DARK_GREEN
]

const BODY_COLORS = [
	Color.WHITE,
	Color.BLUE_VIOLET,
	Color.DARK_BLUE,
	Color.BLACK,
	Color.AQUAMARINE,
	Color.DARK_CYAN,
	Color.LIGHT_GREEN
]

enum DRAW_TYPE { RECT, CIRCLE, ELLIPSE, POLYGON }
enum FEATURE_TYPE { BODY, HEAD, MOUSTACHE, EYES, EYEBROWS }
var feature_params = []

const FIRST_NAME_OPTIONS = ["Alex", "Bob", "Charlie", "Clyde", "Dax", "Edward", "Felipe", "Greg", "Peter", "Spencer", "Zach"]
const LAST_NAME_OPTIONS = ["Smith", "Long", "Wild", "Brown", "Wilson"]



enum CRIME_TYPE { NONE, CAUGHT, STEAL_APPLE, ARSON }
var new_crime : CRIME_TYPE = CRIME_TYPE.NONE






static func constructor(pos : Vector2) -> Person:
	var person = my_scene.instantiate()
	person.position = pos
	person.target = pos
	person.randomize_colors()
	person.randomize_facial_hair()
	person.set_initial_features()	
	person.full_name = FIRST_NAME_OPTIONS.pick_random() + " " + LAST_NAME_OPTIONS.pick_random()
	return person



func _ready():
	set_initial_features()
	# We draw the person once
	queue_redraw()




# This function will add the order of all the features needed for this person
func set_initial_features():
	# BODY
	feature_params.append([FEATURE_TYPE.BODY, DRAW_TYPE.RECT, [Rect2(-(body_width/2), 0, body_width, body_height), body_color]])
	
	# HEAD
	feature_params.append([FEATURE_TYPE.HEAD, DRAW_TYPE.ELLIPSE, [Vector2(0, 0), head_width, head_height, head_color]])
	
	# MOUSTACHE
	if has_moustache:
		var offset : Vector2 = Vector2(0, 2)
		var coords = [
			[offset.x - moustache_radius * moustache_endpoint_ratio, offset.y + moustache_radius * moustache_endpoint_ratio], # left point
			[offset.x + moustache_radius * moustache_endpoint_ratio, offset.y + moustache_radius * moustache_endpoint_ratio], # right point
			[offset.x + moustache_radius * moustache_bridge_ratio, offset.y], # top-right point
			[offset.x, offset.y - moustache_radius * moustache_height_ratio],  # top point
			[offset.x - moustache_radius * moustache_bridge_ratio, offset.y], # top-left point
		]
		var head = float_array_to_Vector2Array(coords)
		feature_params.append([FEATURE_TYPE.MOUSTACHE, DRAW_TYPE.POLYGON, [head, [ moustache_color ]]])
	
	# EYES
	feature_params.append([FEATURE_TYPE.EYES, DRAW_TYPE.CIRCLE, [Vector2(eye_spacing * -1, eye_y_offset), eye_radius, eye_color]])
	feature_params.append([FEATURE_TYPE.EYES, DRAW_TYPE.CIRCLE, [Vector2(eye_spacing, eye_y_offset), eye_radius, eye_color]])
		
	# EYEBROWS
	if has_eyebrows:
		var pivot : Vector2 = Vector2(-eyebrow_spacing - (eyebrow_width/2), eyebrow_y_offset)
		var points = get_rotated_rect(Rect2(0, 0, eyebrow_width, eyebrow_height), eyebrow_rotation, pivot)
		feature_params.append([FEATURE_TYPE.EYEBROWS, DRAW_TYPE.POLYGON, [points, [ eyebrow_color ]]])
		
		pivot = Vector2(eyebrow_spacing - (eyebrow_width/2), eyebrow_y_offset)
		points = get_rotated_rect(Rect2(0, 0, eyebrow_width, eyebrow_height), eyebrow_rotation * -1, pivot)
		feature_params.append([FEATURE_TYPE.EYEBROWS, DRAW_TYPE.POLYGON, [points, [ eyebrow_color ]]])
	


func float_array_to_Vector2Array(coords : Array) -> PackedVector2Array:
	# Convert the array of floats into a PackedVector2Array.
	var array : PackedVector2Array = []
	for coord in coords:
		array.append(Vector2(coord[0], coord[1]))
	return array


func get_rotated_rect(rect : Rect2, degrees : int, pivot : Vector2): # it's not a pivot it's kinda the offset?
	var rotation_angle = deg_to_rad(degrees) # 30 degrees

	# Create a transform with rotation
	var rotation_transform = Transform2D(rotation_angle, Vector2(0, 0))

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
		points[i] = rotation_transform.basis_xform(points[i])
		points[i] += pivot + Vector2(0, -sin(rotation_angle)*eyebrow_rotation/2)
	
	return points
	
	


func _draw_feature_shapes():
	for feature_param in feature_params:
		var feature = feature_param[0]
		var shape = feature_param[1]
		var params = feature_param[2]
		
		if shape == DRAW_TYPE.RECT:
			draw_rect(params[0], params[1])
		elif shape == DRAW_TYPE.ELLIPSE:
			draw_ellipse(params[0], params[1], params[2], params[3])
		elif shape == DRAW_TYPE.POLYGON:
			draw_polygon(params[0], params[1])
		elif shape == DRAW_TYPE.CIRCLE:
			draw_circle(params[0], params[1], params[2])


func _draw():
	if draw_enabled:
		_draw_feature_shapes()


func _process(delta : float):
	
	# wander logic
	if position.distance_to(target) < 1.0:
		# pick a new target
		target = Vector2(randi_range(0, 1000), randi_range(0, 1000))
	else:
		# keep moving to our target
		position = position.move_toward(target, speed * delta)



func randomize_colors():
	head_color_idx = randi_range(0, len(HEAD_COLORS) - 1)
	head_color = HEAD_COLORS[head_color_idx]
	
	hair_color_idx = randi_range(0, len(HAIR_COLORS) - 1)
	eyebrow_color = HAIR_COLORS[hair_color_idx]
	moustache_color = HAIR_COLORS[hair_color_idx]
	
	body_color_idx = randi_range(0, len(BODY_COLORS) - 1)
	body_color = BODY_COLORS[body_color_idx]
		
	eyes_color_idx = randi_range(0, len(EYE_COLORS) - 1)
	eye_color = EYE_COLORS[eyes_color_idx]


func randomize_facial_hair():
	if randf() < 0.4:
		has_moustache = false
	if randf() < 0.1:
		has_eyebrows = false
		


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("click") and not caught:
		caught = true
		print("clicked " + full_name + " with bounty of: " + str(bounty))
		person_clicked.emit(self)
		draw_enabled = false
		queue_redraw()
		

func commit_crime():
	bounty += get_bounty_increase(new_crime)


static func get_bounty_increase(crime : CRIME_TYPE):
	var increase : int = 0
	match crime:
		CRIME_TYPE.NONE:
			pass
		CRIME_TYPE.CAUGHT:
			pass
		CRIME_TYPE.STEAL_APPLE:
			increase = 100
		CRIME_TYPE.ARSON:
			increase = 500
	return increase
	
	
static func get_crime_string(crime : CRIME_TYPE):
	var increase : int = get_bounty_increase(crime)
	match crime:
		CRIME_TYPE.NONE:
			return "No Crime\nCommitted"
		CRIME_TYPE.CAUGHT:
			return ""
		CRIME_TYPE.STEAL_APPLE:
			return "Stole\nApple\n+$" + str(increase)
		CRIME_TYPE.ARSON:
			return "ARSON!\n+$" + str(increase)
			
func start_new_crime():
	# randomly choose a new crime
	if bounty >= 1000:
		new_crime = CRIME_TYPE.ARSON
	else:
		new_crime = CRIME_TYPE.STEAL_APPLE
