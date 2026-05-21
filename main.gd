extends Node2D


const JAIL_CELL_SPACING = 120
const MAX_JAIL_CELLS : int = 9
var num_jail_cells : int = 2
var num_full_cells : int = 0
var arrested_people : Array[Person] = []

var day : int = 0


var people : Array[Person] = []

enum GAME_STATE { POSTERS, CATCHING, STATS }
var game_state : GAME_STATE

var player_money = 0

var fire_scene = preload("res://fire.tscn")
var blood_scene = preload("res://blood.tscn")


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
			HOUSE4TO3,
			
			HOUSE1TOORE,
			HOUSE2TOORE,
			HOUSE3TOORE,
			HOUSE4TOORE,
			
			HOUSE1TOPOT,
			HOUSE2TOPOT,
			HOUSE3TOPOT,
			HOUSE4TOPOT,
			
			HOUSE1TOTOWER,
			HOUSE2TOTOWER,
			HOUSE3TOTOWER,
			HOUSE4TOTOWER,
			
			HOUSE1TOHORSE,
			HOUSE2TOHORSE,
			HOUSE3TOHORSE,
			HOUSE4TOHORSE,
			
			HOUSE1TOSTAGE,
			HOUSE2TOSTAGE,
			HOUSE3TOSTAGE,
			HOUSE4TOSTAGE
}

func _ready():
	
	# Assure all the other overlays are hidden
	$DayOverOverlay.hide()
	$JailIconOverlay.hide()
	$PosterOverlay.hide()
	# Start with the instructions up
	$InstructionsOverlay.show()
	
	Person.generate_person_index_options()
	
	
	# Start with 6 people in town, with one more than the number of jail cells you have
	const NUM_PEOPLE_TO_ADD : int = 6
	const NUM_CRIMINALS_TO_ADD : int = 3
	add_new_arrival_people(NUM_PEOPLE_TO_ADD, NUM_CRIMINALS_TO_ADD)
	
	#Person.feature_tree_root.print()


func _process(delta: float) -> void:
	var end_day : bool = false
	if game_state == GAME_STATE.CATCHING:
		for person in people:
			var delete_person : bool = await person.update_movement(delta)
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
	const DEST_RADIUS = 100
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
		# TO ORE
		PATH_OPTIONS.HOUSE1TOORE:
			points = [$PathingPoints/House1Point.position,
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path0Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/OrePoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE2TOORE:
			points = [$PathingPoints/House2Point.position,
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path0Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/OrePoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE3TOORE:
			points = [$PathingPoints/House3Point.position,
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path0Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/OrePoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE4TOORE:
			points = [$PathingPoints/House4Point.position,
						$PathingPoints/Path7Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path6Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path0Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/OrePoint.position + get_random_vector(DEST_RADIUS)]
		# TO POT
		PATH_OPTIONS.HOUSE1TOPOT:
			points = [$PathingPoints/House1Point.position,
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/PotPoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE2TOPOT:
			points = [$PathingPoints/House2Point.position,
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/PotPoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE3TOPOT:
			points = [$PathingPoints/House3Point.position,
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/PotPoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE4TOPOT:
			points = [$PathingPoints/House4Point.position,
						$PathingPoints/Path7Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path6Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/PotPoint.position + get_random_vector(DEST_RADIUS)]
		# TO TOWER
		PATH_OPTIONS.HOUSE1TOTOWER:
			points = [$PathingPoints/House1Point.position,
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/CenterPath.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/TowerPoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE2TOTOWER:
			points = [$PathingPoints/House2Point.position,
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/CenterPath.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/TowerPoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE3TOTOWER:
			points = [$PathingPoints/House3Point.position,
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/CenterPath.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/TowerPoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE4TOTOWER:
			points = [$PathingPoints/House4Point.position,
						$PathingPoints/Path7Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path6Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/CenterPath.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/TowerPoint.position + get_random_vector(DEST_RADIUS)]
		# TO HORSE
		PATH_OPTIONS.HOUSE1TOHORSE:
			points = [$PathingPoints/House1Point.position,
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/CenterPath.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/HorsePoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE2TOHORSE:
			points = [$PathingPoints/House2Point.position,
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/CenterPath.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/HorsePoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE3TOHORSE:
			points = [$PathingPoints/House3Point.position,
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/CenterPath.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/HorsePoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE4TOHORSE:
			points = [$PathingPoints/House4Point.position,
						$PathingPoints/Path7Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path6Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/CenterPath.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/HorsePoint.position + get_random_vector(DEST_RADIUS)]
		# TO STAGE
		PATH_OPTIONS.HOUSE1TOSTAGE:
			points = [$PathingPoints/House1Point.position,
						$PathingPoints/Path1Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path2Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/StagePoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE2TOSTAGE:
			points = [$PathingPoints/House2Point.position,
						$PathingPoints/Path3Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path4Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/StagePoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE3TOSTAGE:
			points = [$PathingPoints/House3Point.position,
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/StagePoint.position + get_random_vector(DEST_RADIUS)]
		PATH_OPTIONS.HOUSE4TOSTAGE:
			points = [$PathingPoints/House4Point.position,
						$PathingPoints/Path7Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path6Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/Path5Point.position + get_random_vector(MAX_RADIUS),
						$PathingPoints/StagePoint.position + get_random_vector(DEST_RADIUS)]
						
		_:
			print("Path option node found: " + PATH_OPTIONS.keys()[path_option])
			
			
	return points




func add_people_to_scene():
	for person in people:
		person.restart_path()
		$Y_Sorted_Sprites/People.add_child(person)

'''
add_new_arrival_people
this function will create the desired number of people/criminals in the scene
'''
func add_new_arrival_people(num_people : int, num_criminals : int):
	const MAX_PEOPLE_IN_SCENE : int = 40
	for i in range(num_people):
		# Only generate a certain number of people
		if len(people) >= MAX_PEOPLE_IN_SCENE:
			break
		
		var person : Person = Person.constructor(get_random_path())
		# When this person is clicked, we need to register back to this game engine
		person.person_clicked.connect(_on_person_clicked)
		
		# Only add the desired number of criminals
		if num_criminals > 0:
			person.bounty = randi_range(1, 3) * 100
			num_criminals -= 1
		else:
			person.bounty = 0
		
		people.append(person)


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
	for i in range(num_jail_cells):
		var jail_icon = JailIcon.constructor(Vector2(JAIL_CELL_SPACING * i, 0))
		$JailIconOverlay/JailIcons.add_child(jail_icon)


func clear_people_from_scene():
	for child in $Y_Sorted_Sprites/People.get_children():
		$Y_Sorted_Sprites/People.remove_child(child)
		#child.queue_free() # I'm never freeing old people


func remove_arrested_people():
	for arrested_person in arrested_people:
		people.remove_at(people.find(arrested_person)) # unsafe, could be -1


func is_free_town():
	# the town is free from criminals if at least one person has a bounty
	for person in people:
		if person.bounty > 0:
			return false
	return true

'''
The start day function will first show all of the wanted posters
'''
func start_day():
	
	day += 1
	print("Starting day " + str(day) + "...")
	$DayOverOverlay.hide()
	$PosterOverlay/PosterOverlayControls/DayLabel.text = "Day " + str(day)
	
	remove_arrested_people()
	
	# Add more people (if they haven't already won)
	if day > 1 and not is_free_town():
		const NUM_PEOPLE_TO_ADD : int = 6
		var num_criminals_to_add : int = randi_range(2, 3)
		add_new_arrival_people(NUM_PEOPLE_TO_ADD, num_criminals_to_add)
	
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
	perform_crimes()
		
	game_state = GAME_STATE.STATS


func perform_crimes():
	for person in people:
		person.increase_bounty_for_crime()
		
		if person.new_crime == Person.CRIME_TYPE.ARSON:
			# Add a fire instance on one of the four buildings
			var house_index : int = randi_range(1, 4)
			var house_position : Vector2
			match house_index:
				1:
					house_position = $Houses/House.position
				2:
					house_position = $Houses/House2.position
				3:
					house_position = $Houses/House3.position
				4:
					house_position = $Houses/House4.position
			
			var fire_instance = fire_scene.instantiate()
			# Place the fire somewhere on the house
			fire_instance.position = house_position + Vector2(randi_range(-100, 100),
															  randi_range(-100, 100))
			$FireAndBlood.add_child(fire_instance)
			
		elif person.new_crime == Person.CRIME_TYPE.MURDER:
			# Add a new blood sprite on the path
			var blood_instance = blood_scene.instantiate()
			blood_instance.position = Vector2(randi_range(0, 1920),
											  randi_range(620, 750))
			$FireAndBlood.add_child(blood_instance)
			# TODO should we kill someone random? YES!!!

'''
Updates the value and the label
'''
func add_player_money(amount):
	player_money += amount
	$JailIconOverlay/MoneyLabel.text = "$" + str(player_money)


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
	add_player_money(person.bounty)
	
	# Guard against overflow
	if num_full_cells < num_jail_cells:
		$JailIconOverlay/JailIcons.get_child(num_full_cells).add_person(person)
		num_full_cells += 1
		arrested_people.append(person)
	
	if num_full_cells == num_jail_cells:
		print("full cells!")
		end_day()


func _on_catch_label_timer_timeout() -> void:
	$JailIconOverlay/CatchLabel.hide()


func _on_buy_cell_button_pressed() -> void:
	const CELL_COST : int = 500
	
	# Check they can buy it
	if player_money >= CELL_COST:
		add_player_money(-1 * CELL_COST)
		
	
		var jail_icon = JailIcon.constructor(Vector2(JAIL_CELL_SPACING * num_jail_cells, 0))
		$JailIconOverlay/JailIcons.add_child(jail_icon)
		
		$JailIconOverlay/BuyCellButton.position += Vector2(JAIL_CELL_SPACING, 0)
		
		num_jail_cells += 1
		
		if num_jail_cells >= MAX_JAIL_CELLS:
			$JailIconOverlay/BuyCellButton.hide()
	else:
		# Re-purpose the catch label to give feedback to the player
		$JailIconOverlay/CatchLabel.text = "Not enough money to buy cell!"
		$JailIconOverlay/CatchLabel/CatchLabelTimer.stop() # reassure it is off to prevent a race-condition turning it off
		$JailIconOverlay/CatchLabel.show()
		$JailIconOverlay/CatchLabel/CatchLabelTimer.start()
	


func _on_play_game_button_pressed() -> void:
	$InstructionsOverlay.hide()
	start_day()
