class_name JailIcon extends Node2D



const my_scene : PackedScene = preload("res://jail_icon.tscn")


static func constructor(pos : Vector2) -> JailIcon:
	var jail_icon = my_scene.instantiate()
	jail_icon.position = pos
	return jail_icon



func add_person(person : Person):
	$NameLabel.text = person.full_name
	$BountyLabel.text = "$" + str(person.bounty)
	$PosterHead.draw_head(person)
