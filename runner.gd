extends Node2D

var project = {}

func _ready():
	var file = File.new()
	file.open("user://"+global.project+"/scn_"+global.scene+".json", File.READ)
	project = parse_json(file.get_as_text())
	file.close()
	for item in project:
		if project[item]['type'] == "static": # TMP only allow static for now
			# TODO if obj is part of a group, just skip this part and clone the node
		
			var obj_load = load("res://object_types/"+project[item]['type']+"/obj.tscn") #for some reason item['loc'] is not working
			var obj = obj_load.instance()
			obj.set_position(Vector2(project[item]['pos_x'],project[item]['pos_y']))
			var sprite_frames = obj.get_node("sprites").get_sprite_frames().duplicate(true)
			obj.get_node("sprites").set_sprite_frames(sprite_frames)
			var anims = ['default'] # TODO get dirs
			for anim in anims:
				var sprites = 10 # TODO count files
				for i in range(1,sprites+1):
					var sprite = ImageTexture.new()
					sprite.load(project[item]['loc']+"/frames/"+anim+"/frame_"+str(i)+".png")
					obj.get_node("sprites").get_sprite_frames().add_frame(anim,sprite)
			
			obj.gg_set_animation(project[item]['anim'])
			obj.gg_set_frame(project[item]['frame'])
			add_child(obj)

func _on_back_button_down():
	get_tree().change_scene("res://main.tscn")
