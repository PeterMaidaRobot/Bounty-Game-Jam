extends Node2D


func _ready():
	## Generate a lot of people!!!
	#for i in range(200):	
		#var player_pos = Vector2(randi_range(0, 500), randi_range(0, 500))
		#var bob : Person = Person.constructor(player_pos)
		#$Y_Sorted_Sprites/People.add_child(bob)


	# Generate a list of wanted criminals, display their posters

	var player_pos = Vector2(randi_range(0, 500), randi_range(0, 500))
	var bob : Person = Person.constructor(player_pos)
	
	# Create a wanted poster for this person
	var poster_pos : Vector2 = Vector2(200, 200)
	for i in range(3):
		var poster : Poster = Poster.constructor(bob, poster_pos)
		$Posters.add_child(poster)
		poster_pos.x += 200
