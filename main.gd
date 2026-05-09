extends Node2D


func _ready():
	
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



func _on_begin_button_pressed() -> void:
	$PosterOverlay.hide()
