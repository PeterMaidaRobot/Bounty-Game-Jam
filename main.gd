extends Node2D


const MAX_JAIL_CELLS = 4
var num_full_cells = 0


func _ready():
	
	# Generate empty jail cell icons
	const JAIL_CELL_SPACING = 120
	for i in range(MAX_JAIL_CELLS):
		var jail_icon = JailIcon.constructor(Vector2(JAIL_CELL_SPACING * i, 0))
		$JailIcons.add_child(jail_icon)
	
	
	
	var initial_poster_pos : Vector2 = Vector2(200, 200)
	var poster_pos : Vector2 = initial_poster_pos
	var poster_count : int = 0
	const POSTER_X_SPACING : int = 200
	const POSTER_Y_SPACING : int = 300
	
	## Generate a lot of people!!!
	for i in range(20):
		var player_pos = Vector2(randi_range(0, 1000), randi_range(0, 1000))
		var person : Person = Person.constructor(player_pos)
		$Y_Sorted_Sprites/People.add_child(person)
		
		# When this person is clicked, we need to register back to this game engine
		person.person_clicked.connect(_on_person_clicked)
		
		# Add a poster if this person is wanted
		person.bounty = randi_range(0, 2) * 100
		if person.bounty > 0:
			poster_count += 1
			var poster : Poster = Poster.constructor(person, poster_pos)
			$PosterOverlay/Posters.add_child(poster)
			poster_pos.x += POSTER_X_SPACING
			if poster_count % 8 == 0:
				poster_pos.x = initial_poster_pos.x
				poster_pos.y += POSTER_Y_SPACING
				
		


func end_day():
	print("Ending day...")


func _on_begin_button_pressed() -> void:
	$PosterOverlay.hide()
	
func _on_person_clicked(person : Person):
	print("Caught: " + person.full_name)
	$CatchLabel.text = "Arrested " + person.full_name + "\n Bounty of " + str(person.bounty)
	$CatchLabel/CatchLabelTimer.stop() # reassure it is off to prevent a race-condition turning it off
	$CatchLabel.show()
	$CatchLabel/CatchLabelTimer.start()
	
	# Guard against overflow
	if num_full_cells < MAX_JAIL_CELLS:
		$JailIcons.get_child(num_full_cells).add_person(person)
		num_full_cells += 1
	
	if num_full_cells == MAX_JAIL_CELLS:
		print("full cells!")
		end_day()


func _on_catch_label_timer_timeout() -> void:
	$CatchLabel.hide()
