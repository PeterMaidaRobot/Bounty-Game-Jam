class_name Poster extends Node2D



const my_scene : PackedScene = preload("res://poster.tscn")


static func constructor(person : Person, pos : Vector2) -> Poster:
	var poster = my_scene.instantiate()
	poster.position = pos
	poster.draw_head(person)
	return poster


func draw_head(person : Person):
	$BountyLabel.text = "$" + str(person.bounty)
	$NameLabel.text = person.full_name
	$PosterHead.draw_head(person)


func show_jail():
	$JailSprite.show()
	$CaughtLabel.show()
	
func show_crime(crime : Person.CRIME_TYPE):
	$CrimeLabel.text = Person.get_crime_string(crime)
	$CrimeLabel.show()

func get_name_label():
	return $NameLabel.text
