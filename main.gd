extends Node2D


const MAX_JAIL_CELLS : int = 4
var num_full_cells : int = 0
var arrested_people : Array[Person] = []

var day : int = 0


var people : Array[Person] = []


func _ready():
	
	$DayOverOverlay.hide()
	$JailIconOverlay.hide()
	
	## Generate a lot of people!!!
	for i in range(8):
		var player_pos = Vector2(randi_range(0, 1000), randi_range(0, 1000))
		var person : Person = Person.constructor(player_pos)
		
		# When this person is clicked, we need to register back to this game engine
		person.person_clicked.connect(_on_person_clicked)
		
		person.bounty = randi_range(0, 2) * 100
		
		people.append(person)
		
	start_day()


func add_people_to_scene():
	print(people)
	for person in people:
		print("adding " + person.full_name)
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
		print("removing " + arrested_person.full_name)
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
					person.new_crime = Person.CRIME_TYPE.STEAL_APPLE
					poster.show_crime(person.new_crime)
				break
	
	# Commit crimes
	for person in people:
		person.commit_crime()


'''
The BEGIN button is pressed when starting a new day
'''
func _on_begin_button_pressed() -> void:
	print("Begin pressed.")
	$PosterOverlay.hide()
	add_people_to_scene()
	$JailIconOverlay.show()


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
