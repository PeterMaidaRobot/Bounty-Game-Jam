class_name Poster extends Node2D




const my_scene : PackedScene = preload("res://poster.tscn")


static func constructor(person : Person, pos : Vector2) -> Poster:
	var poster = my_scene.instantiate()
	poster.position = pos
	return poster
