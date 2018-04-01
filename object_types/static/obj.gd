extends StaticBody2D

var gg_offset = Vector2(0,0)

func _ready():
	set_position(get_position()+gg_offset)
	print(gg_offset)

func gg_set_animation(animation):
	pass

func gg_set_frame(frame):
	$sprites.set_frame(frame-1)