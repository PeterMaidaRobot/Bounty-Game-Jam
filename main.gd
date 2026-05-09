extends Node2D

func _ready():
	var player_pos = Vector2(200, 200)
	var bob = Person.constructor(player_pos)
	add_child(bob)
	player_pos = Vector2(300, 200)
	bob = Person.constructor(player_pos)
	add_child(bob)
	
	
#func _process(delta):
	#update_person()
	
