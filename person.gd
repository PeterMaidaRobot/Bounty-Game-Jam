class_name Person extends Node2D


@export_group("Body")
@export var body_width : int = 25
@export var body_height : int = 50
@export var body_color : Color = Color.SADDLE_BROWN

@export_group("Eyebrow")
@export var has_eyebrows : bool = true
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
@export var has_moustache : bool = true
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

const MAX_SPEED : int = 100

var target : Vector2
var speed : int = 1000 # 100 #30 # 10 is a casual speed
var full_name : String = "Bob Smith"
var bounty : int = 0 # if the bounty is zero, they aren't a criminal
var caught : bool = false



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
	Color.BLACK,
	Color.WEB_GREEN
]

const HEAD_COLORS = [
	#Color.YELLOW,
	Color.ROSY_BROWN,
	Color.SANDY_BROWN,
	#Color.SADDLE_BROWN,
	Color.BLANCHED_ALMOND,
	Color.SALMON,
	Color.PERU,
	Color.SIENNA
]

const HAIR_COLORS = [
	Color.WHITE,
	Color.GRAY,
	Color.INDIAN_RED,
	Color.YELLOW,
	Color.SADDLE_BROWN,
	Color.BLACK,
	Color.DARK_GREEN,
	Color.HOT_PINK,
	Color.DARK_BLUE
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


var path : Array[Vector2]
var path_node_idx : int = 0
var going_home : bool = false
const INITIAL_ACTIVITY_WAIT_TIME : float = 5
var activity_wait_time : float = INITIAL_ACTIVITY_WAIT_TIME



static var available_name_indices = [] #: Array[Dictionary[String, int]]
const FIRST_NAME_IDX_KEY : String = "first_name_idx"
const LAST_NAME_IDX_KEY : String = "last_name_idx"

static var feature_tree_root
const HEAD_COLOR_KEY : String = "head_color"
const EYE_COLOR_KEY : String = "eye_color"
const HAIR_COLOR_KEY : String = "hair_color"
const MOUSTACHE_TYPE_KEY : String = "moustache_type"
const EYEBROW_TYPE_KEY : String = "eyebrow_type"

enum MOUSTACHE_TYPE { NONE, THICK }
enum EYEBROW_TYPE { NONE, THICK }

# Create a treenode structure to house the feature options
class TreeNode:
	var children : Array[TreeNode]
	var weight : int = 1  # The weight will default to 1 unless otherwise overridden
	var key : String
	var value # this might be a color, moustache_type enum, or eyebrow_type enum dynamic type
	
	func _init(key : String, value) -> void:
		self.key = key
		self.value = value
	
	func print(depth=0):
		var s : String = ""
		for i in range(depth):
			s = s + "-"
		print(s + key + " " + str(value) + " (weight " + str(weight) +") has:")
		for child in children:
			child.print(depth+1)
		
	


static func constructor(path_points : Array[Vector2]) -> Person:
	var person = my_scene.instantiate()
	person.position = path_points[0]
	person.target = path_points[1]
	
	person.generate_unique_person()
	person.set_initial_features()
	
	person.path = path_points
	person.speed = MAX_SPEED * randf_range(0.3, 1)
	return person




static func _get_eyebrow_type_children():
	var eyebrow_type_children : Array[TreeNode] = []
	for eyebrow_type in EYEBROW_TYPE:
		var new_eyebrow_node = TreeNode.new(EYEBROW_TYPE_KEY, eyebrow_type)
		#  <---  no children to add here yet
		match EYEBROW_TYPE.get(eyebrow_type):
			EYEBROW_TYPE.NONE:
				new_eyebrow_node.weight = 1
			EYEBROW_TYPE.THICK:
				new_eyebrow_node.weight = 4
		eyebrow_type_children.append(new_eyebrow_node)
	return eyebrow_type_children


static func _get_moustache_type_children():
	var moustache_type_children : Array[TreeNode] = []
	for moustache_type in MOUSTACHE_TYPE:
		var new_moustache_node = TreeNode.new(MOUSTACHE_TYPE_KEY, moustache_type)
		new_moustache_node.children = _get_eyebrow_type_children()
		match MOUSTACHE_TYPE.get(moustache_type):
			MOUSTACHE_TYPE.NONE:
				new_moustache_node.weight = 2
			MOUSTACHE_TYPE.THICK:
				new_moustache_node.weight = 3
		moustache_type_children.append(new_moustache_node)
	return moustache_type_children


static func _get_hair_color_children():
	var hair_color_children : Array[TreeNode] = []
	for hair_color in HAIR_COLORS:
		var new_hair_node = TreeNode.new(HAIR_COLOR_KEY, hair_color)
		new_hair_node.children = _get_moustache_type_children()
		hair_color_children.append(new_hair_node)
	return hair_color_children


static func _get_eye_color_children():
	var eye_color_children : Array[TreeNode] = []
	for eye_color in EYE_COLORS:
		var new_eye_node = TreeNode.new(EYE_COLOR_KEY, eye_color)
		new_eye_node.children = _get_hair_color_children()
		eye_color_children.append(new_eye_node)
	return eye_color_children


static func _get_head_color_children():
	var head_color_children : Array[TreeNode] = []
	for head_color in HEAD_COLORS:
		var new_head_node = TreeNode.new(HEAD_COLOR_KEY, head_color)
		new_head_node.children = _get_eye_color_children()
		head_color_children.append(new_head_node)
	return head_color_children

'''
Generates the main tree that will have leaves removed as options become inaccessible
'''
static func generate_person_index_options():
	# Generate the name options
	for first_name_idx in range(len(FIRST_NAME_OPTIONS)):
		for last_name_idx in range(len(LAST_NAME_OPTIONS)):
			Person.available_name_indices.append({FIRST_NAME_IDX_KEY : first_name_idx,
										   LAST_NAME_IDX_KEY : last_name_idx})
	
	# Generate the feature options
	feature_tree_root = TreeNode.new("root", null)
	feature_tree_root.children = _get_head_color_children()
	#feature_tree_root.print()


'''
ROOT
-> HEAD COLOR
----> EYE COLOR
-------> HAIR COLOR
----------> MOUSTACHE TYPE
--------------> EYEBROW TYPE
'''


'''
Use the feature tree to generate an available option, and remove it from the tree
'''
static func get_random_feature_set(node): # (make a person)
	
	# Find out what child to use via the weighting
	# Weighted is {0->idx, 1->idx, ...}
	var weighted = {}
	var total = 0
	for child_idx in range(len(node.children)):
		var child = node.children[child_idx]
		for i in range(child.weight):
			weighted[total] = child_idx
			total += 1
	
	var rand_idx = randi_range(0, total - 1)
	var child_idx = weighted[rand_idx]
	var child = node.children[child_idx]
	
	var feature_dict = {}
	# recursively get the rest of this dictionary, child
	if len(child.children) > 0:
		feature_dict = get_random_feature_set(child)
	
	# Delete the child if there's no leaves under it, but check after it's grandchild may have deleted some
	if len(child.children) == 0:
		node.children.remove_at(child_idx)
	
	feature_dict[child.key] = child.value
	
	
	return feature_dict



func _ready():
	set_initial_features() # set this here also for ones we make in the editor
	# We draw the person once
	queue_redraw()


func generate_unique_person():
	
	if len(available_name_indices) == 0:
		print("ERROR: no more name options!")
		full_name = "<null>"
	else:
		var available_name_idx = randi_range(0, len(available_name_indices) - 1)
		var first_name : String = FIRST_NAME_OPTIONS[available_name_indices[available_name_idx][FIRST_NAME_IDX_KEY]]
		var last_name : String = LAST_NAME_OPTIONS[available_name_indices[available_name_idx][LAST_NAME_IDX_KEY]]
		full_name = first_name + " " + last_name
		# remove this option from those available
		available_name_indices.remove_at(available_name_idx)
	
	
	var feature_set
	if len(feature_tree_root.children) > 0:
		feature_set = get_random_feature_set(feature_tree_root)
		#print(feature_set)
		#feature_tree_root.print()
		# TODO there's a bug with bald people having different hair colors but you can't tell!! I rigged the probablities to make it unlikely...
	else:
		print("ERROR: no other options for character generation!")
		# Make a default feature set in this error case to not crash
		feature_set = {
			MOUSTACHE_TYPE_KEY : MOUSTACHE_TYPE.NONE,
			EYEBROW_TYPE_KEY : EYEBROW_TYPE.NONE,
			HEAD_COLOR_KEY : HEAD_COLORS[0],
			HAIR_COLOR_KEY : HAIR_COLORS[0],
			EYE_COLOR_KEY : EYE_COLORS[0]
		}
	
	
	has_moustache = MOUSTACHE_TYPE.get(feature_set[MOUSTACHE_TYPE_KEY]) != MOUSTACHE_TYPE.NONE
	has_eyebrows = EYEBROW_TYPE.get(feature_set[EYEBROW_TYPE_KEY]) != EYEBROW_TYPE.NONE
	
	head_color = feature_set[HEAD_COLOR_KEY]
	eyebrow_color = feature_set[HAIR_COLOR_KEY]
	moustache_color = feature_set[HAIR_COLOR_KEY]
	eye_color = feature_set[EYE_COLOR_KEY]
	
	
	# Body clothes color can overlap, we only care about the face for uniqueness
	body_color_idx = randi_range(0, len(BODY_COLORS) - 1)
	body_color = BODY_COLORS[body_color_idx]



func restart_path():
	position = path[0]
	path_node_idx = 1
	target = path[path_node_idx]
	going_home = false
	activity_wait_time = INITIAL_ACTIVITY_WAIT_TIME



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
		#for point in path: # DEBUG PATH
			#draw_circle(point - position, 10, Color.RED)


func _process(delta : float):
	queue_redraw() # I only use this for debug, this doesn't need to be here

func update_movement(delta : float) -> bool:
	var delete_me : bool = false
	# wander logic
	if going_home and activity_wait_time > 0:
		activity_wait_time -= delta
	elif position.distance_to(target) < 1.0:
		if path_node_idx == -1 and going_home:
			# Went to destination, and got back home. Delete now
			delete_me = true
		elif path_node_idx >= len(path) and not going_home:
			# End of the path, go backwards
			going_home = true
			path_node_idx -= 1
		else:
			# Grab the next target in the list
			target = path[path_node_idx]
			if going_home:
				path_node_idx -= 1
			else:
				path_node_idx += 1
	else:
		# keep moving to our target
		position = position.move_toward(target, speed * delta)
		
	return delete_me



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
