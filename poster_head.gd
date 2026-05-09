class_name PosterHead extends Node2D


var person : Person = null

func _draw() -> void:
	if person != null:
		# Draw the features for this person on the wanted poster
		for feature_param in person.feature_params:
			var feature = feature_param[0]
			var shape = feature_param[1]
			var params = feature_param[2]
			
			# Don't draw the body in the portrait
			if feature == Person.FEATURE_TYPE.BODY:
				continue
			
			if shape == Person.DRAW_TYPE.RECT:
				draw_rect(params[0], params[1])
			elif shape == Person.DRAW_TYPE.ELLIPSE:
				draw_ellipse(params[0], params[1], params[2], params[3])
			elif shape == Person.DRAW_TYPE.POLYGON:
				draw_polygon(params[0], params[1])
			elif shape == Person.DRAW_TYPE.CIRCLE:
				draw_circle(params[0], params[1], params[2])



func draw_head(person_input : Person):
	person = person_input
	queue_redraw()
