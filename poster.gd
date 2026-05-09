class_name Poster extends Node2D



const my_scene : PackedScene = preload("res://poster.tscn")


static func constructor(person : Person, pos : Vector2) -> Poster:
	var poster = my_scene.instantiate()
	poster.position = pos
	poster.draw_head(person)
	return poster


func draw_head(person : Person):
	$BountyLabel.text = "$" + str(person.bounty)
	$PosterHead.draw_head(person)
