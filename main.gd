extends Node2D


func _ready():
	# Generate a lot of people!!!
	for i in range(200):	
		var player_pos = Vector2(randi_range(0, 500), randi_range(0, 500))
		var bob : Person = Person.constructor(player_pos)
		$Y_Sorted_Sprites/People.add_child(bob)
