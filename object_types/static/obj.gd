# WIP - not usable yet

extends StaticBody2D


func _ready():
	pass

func gg_import_media(media):
	print(media)
	var anims = ['default'] # TODO get dirs
	for anim in anims:
		var sprites = 10 # TODO count files
		for i in range(1,sprites+1):
			var sprite = ImageTexture.new()
			sprite.load(media+"/frames/"+anim+"/frame_"+str(i)+".png")
			$sprites.get_sprite_frames().add_frame(anim,sprite)

func gg_set_animation(animation):
	pass

func gg_set_frame(frame):
	$sprites.set_frame(frame-1)