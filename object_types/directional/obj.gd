extends KinematicBody2D

var gg_offset = Vector2(0,0)
var gg_prop = {}

var allow_movement = true
var speed = 2
var move_x = 0
var move_y = 0

func _ready():
	set_position(get_position()+gg_offset)

	allow_movement = int(gg_prop["move_on_start"])
	speed = int(gg_prop['speed'])

	if gg_prop['initial_direction'] == "Top":
		move_y = -speed
	elif gg_prop['initial_direction'] == "Top Left":
		move_x = -speed
		move_y = -speed
	elif gg_prop['initial_direction'] == "Top Right":
		move_x = speed
		move_y = -speed
	elif gg_prop['initial_direction'] == "Bottom":
		move_y = speed
	elif gg_prop['initial_direction'] == "Bottom Left":
		move_x = -speed
		move_y = speed
	elif gg_prop['initial_direction'] == "Bottom Right":
		move_x = speed
		move_y = speed
	elif gg_prop['initial_direction'] == "Left":
		move_x = -speed
	elif gg_prop['initial_direction'] == "Right":
		move_x = speed

		
	set_process(true)

func gg_set_animation(animation):
	pass

func gg_set_frame(frame):
	$sprites.set_frame(frame-1)
	
func _process(delta):
	if allow_movement:
		move_and_collide(Vector2(move_x,move_y))

func _on_area_area_entered(area):
	#print(area.get_parent().get_name())
	pass
