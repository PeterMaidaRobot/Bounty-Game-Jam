extends Node2D


const MAX_JAIL_CELLS : int = 4
var num_full_cells : int = 0
var arrested_people : Array[Person] = []

var day : int = 0


var people : Array[Person] = []

enum GAME_STATE { POSTERS, CATCHING, STATS }
var game_state : GAME_STATE


enum PATH_OPTIONS {
			HOUSE1TO2,
			HOUSE1TO3,
			HOUSE1TO4,
			
			HOUSE2TO1,
			HOUSE2TO3,
			HOUSE2TO4,
			
			HOUSE3TO1,
			HOUSE3TO2,
			HOUSE3TO4,
			
			HOUSE4TO1,
			HOUSE4TO2,
			HOUSE4TO3
}

func _ready():
	
	$DayOverOverlay.hide()
	$JailIconOverlay.hide()
	
	Person.generate_person_index_options()
	## Generate a lot of people!!!
	for i in range(32):
		var person : Person = Person.constructor(get_random_path())
		
		# When this person is clicked, we need to register back to this game engine
		person.person_clicked.connect(_on_person_clicked)
		
		person.bounty = 1
		#person.bounty = randi_range(0, 2) * 100
		#print(person.path)
		
		people.append(person)
		
	Person.feature_tree_root.print()
	start_day()


func _process(delta: float) -> void:
	var end_day : bool = false
	if game_state == GAME_STATE.CATCHING:
		for person in people:
			var delete_person : bool = person.update_movement(delta)
			if delete_person:
				for child in $Y_Sorted_Sprites/People.get_children():
					if child == person:
						$Y_Sorted_Sprites/People.remove_child(child)
						# if this was the last person, end the day # TODO this should be more scheduled... what if they click before they end? maybe always have more than the number of jail cells...
						if $Y_Sorted_Sprites/People.get_child_count() == 0:
							end_day = true
						break
	if end_day:
		end_day()



'''
Get a random point in a circle of max_radius
'''
func get_random_vector(max_radius):
	var angle = randf_range(0, 2*PI)
	var magnitude = randf_range(0, max_radius)
	return Vector2.RIGHT.rotated(angle) * magnitude


func get_random_path() -> Array[Vector2]: # TODO please actually use a graphing library...
	const MAX_RADIUS = 100
	var points : Array[Vector2]	
	var path_option : PATH_OPTIONS = PATH_OPTIONS.values().pick_random()
	
	match path_option:
		PATH_OPTIONS.HOUSE1TO2:
			points = [$PathingPoints/House1Point.position,
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/House2Point.position]
		PATH_OPTIONS.HOUSE1TO3:
			points = [$PathingPoints/House1Point.position,
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/House3Point.position]
		PATH_OPTIONS.HOUSE1TO4:
			points = [$PathingPoints/House1Point.position,
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path6Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path7Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/House3Point.position]
		PATH_OPTIONS.HOUSE2TO1:
			points = [$PathingPoints/House2Point.position,
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/House1Point.position]
		PATH_OPTIONS.HOUSE2TO3:
			points = [$PathingPoints/House2Point.position,
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/House3Point.position]
		PATH_OPTIONS.HOUSE2TO4:
			points = [$PathingPoints/House2Point.position,
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path6Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path7Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/House4Point.position]
		PATH_OPTIONS.HOUSE3TO1:
			points = [$PathingPoints/House3Point.position,
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/House1Point.position]
		PATH_OPTIONS.HOUSE3TO2:
			points = [$PathingPoints/House3Point.position,
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/House2Point.position]
		PATH_OPTIONS.HOUSE3TO4:
			points = [$PathingPoints/House3Point.position,
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path6Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path7Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/House4Point.position]
		PATH_OPTIONS.HOUSE4TO1:
			points = [$PathingPoints/House4Point.position,
						$PathingPoints/Path7Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path6Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/House1Point.position]
		PATH_OPTIONS.HOUSE4TO2:
			points = [$PathingPoints/House4Point.position,
						$PathingPoints/Path7Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path6Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/House2Point.position]
		PATH_OPTIONS.HOUSE4TO3:
			points = [$PathingPoints/House4Point.position,
						$PathingPoints/Path7Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path6Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/House3Point.position]
		_:
			print("Path option node found: " + PATH_OPTIONS.keys()[path_option])
			
			
	return points




func add_people_to_scene():
	for person in people:
		person.restart_path()
		$Y_Sorted_Sprites/People.add_child(person)


func add_new_arrival_people():
	pass # TODO add more people for the number of caravans tha arrive?


func generate_wanted_posters():
	var poster_count : int = 0
	var initial_poster_pos : Vector2 = Vector2(200, 300)
	var poster_pos : Vector2 = initial_poster_pos
	const POSTER_X_SPACING : int = 200
	const POSTER_Y_SPACING : int = 300
	
	$PosterOverlay.show()
	
	# Clear the old posters before making new ones
	for child in $PosterOverlay/Posters.get_children():
		child.queue_free()
	
	# Loop through the people in the scene and create posters for them
	for person in people:
		# Add a poster if this person is wanted
		if person.bounty > 0:
			poster_count += 1
			var poster : Poster = Poster.constructor(person, poster_pos)
			$PosterOverlay/Posters.add_child(poster)
			poster_pos.x += POSTER_X_SPACING
			if poster_count % 8 == 0:
				poster_pos.x = initial_poster_pos.x
				poster_pos.y += POSTER_Y_SPACING
	
	# if no posters left, you win!
	if poster_count == 0:
		$PosterOverlay/PosterOverlayControls/GameWinLabel.show()
		$PosterOverlay/PosterOverlayControls/BeginButton.hide()


func regenerate_jail_icons():
	# Clear the old ones first
	num_full_cells = 0
	arrested_people = []
	for child in $JailIconOverlay/JailIcons.get_children():
		child.queue_free()
	
	# Generate empty jail cell icons
	const JAIL_CELL_SPACING = 120
	for i in range(MAX_JAIL_CELLS):
		var jail_icon = JailIcon.constructor(Vector2(JAIL_CELL_SPACING * i, 0))
		$JailIconOverlay/JailIcons.add_child(jail_icon)


func clear_people_from_scene():
	for child in $Y_Sorted_Sprites/People.get_children():
		$Y_Sorted_Sprites/People.remove_child(child)
		#child.queue_free() # I'm never freeing old people


func remove_arrested_people():
	for arrested_person in arrested_people:
		people.remove_at(people.find(arrested_person)) # unsafe, could be -1


'''
The start day function will first show all of the wanted posters
'''
func start_day():
	day += 1
	print("Starting day " + str(day) + "...")
	$DayOverOverlay.hide()
	$PosterOverlay/PosterOverlayControls/DayLabel.text = "Day " + str(day)
	
	remove_arrested_people()
	
	add_new_arrival_people()
	
	$PosterOverlay/PosterOverlayControls.show()
	generate_wanted_posters()
	
	regenerate_jail_icons()
	
	game_state = GAME_STATE.POSTERS

'''
The end day function will show the stats before moving to the next overlay
'''
func end_day():
	print("Ending day...")
	clear_people_from_scene()
	$DayOverOverlay/DayCompleteLabel.text = "Day " + str(day) + " Complete"
	$DayOverOverlay.show()
	$JailIconOverlay.hide()
	
	$PosterOverlay/PosterOverlayControls.hide()
	generate_wanted_posters()
	# Add the jail cell if they are
	for child in $PosterOverlay/Posters.get_children():
		var poster : Poster = child as Poster
		var person_arrested : bool = false
		for person in arrested_people:
			if poster.get_name_label() == person.full_name:
				person_arrested = true
				break
		
		# Set a crime for the person in the poster # TODO this code is sooo bad 
		for person in people:
			if poster.get_name_label() == person.full_name:
				if person_arrested:
					poster.show_jail()
					person.new_crime = Person.CRIME_TYPE.CAUGHT
				else:
					person.start_new_crime()
					poster.show_crime(person.new_crime)
				break
	
	# Commit crimes
	for person in people:
		person.commit_crime()
		# TODO burn a building if the crime is ARSON
		
	game_state = GAME_STATE.STATS


'''
The BEGIN button is pressed when starting a new day
'''
func _on_begin_button_pressed() -> void:
	print("Begin pressed.")
	$PosterOverlay.hide()
	add_people_to_scene()
	$JailIconOverlay.show()
	
	game_state = GAME_STATE.CATCHING


func _on_person_clicked(person : Person):
	#print("Caught: " + person.full_name)
	$JailIconOverlay/CatchLabel.text = "Arrested " + person.full_name + " with $" + str(person.bounty) + " bounty"
	$JailIconOverlay/CatchLabel/CatchLabelTimer.stop() # reassure it is off to prevent a race-condition turning it off
	$JailIconOverlay/CatchLabel.show()
	$JailIconOverlay/CatchLabel/CatchLabelTimer.start()
	
	# Guard against overflow
	if num_full_cells < MAX_JAIL_CELLS:
		$JailIconOverlay/JailIcons.get_child(num_full_cells).add_person(person)
		num_full_cells += 1
		arrested_people.append(person)
	
	if num_full_cells == MAX_JAIL_CELLS:
		print("full cells!")
		end_day()


func _on_catch_label_timer_timeout() -> void:
	$JailIconOverlay/CatchLabel.hide()
