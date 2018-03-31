extends Node2D

var project = {}
var groups = []

func _ready():
	OS.set_window_size(Vector2(800,600))
	var file = File.new()
	file.open("user://"+global.project+"/scn_"+global.scene+".json", File.READ)
	project = parse_json(file.get_as_text())
	file.close()
	for item in project:
		if project[item]['type'] == "static": # TMP only allow static for now
			var obj
			# TODO if obj is part of a group, just skip this part and clone the node
			if groups.find(project[item]['group']) == -1:
				var obj_load = load("res://object_types/"+project[item]['type']+"/obj.tscn") #for some reason item['loc'] is not working
				obj = obj_load.instance()
				var sprite_frames = obj.get_node("sprites").get_sprite_frames().duplicate(true)
				obj.get_node("sprites").set_sprite_frames(sprite_frames)
				var c_frame = ImageTexture.new()
				c_frame.load(project[item]['loc']+"/frames/default/frame_1.png") # TODO should it be frame specific ?
				var c_size = c_frame.get_size() / 2
				var shape = obj.get_node("collision").get_shape().duplicate(true)
				obj.get_node("collision").set_shape(shape)
				obj.get_node("collision").get_shape().set_extents(c_size)
				var anims = ['default'] # TODO get dirs
				for anim in anims:
					var sprites = 10 # TODO count files
					for i in range(1,sprites+1):
						var sprite = ImageTexture.new()
						sprite.load(project[item]['loc']+"/frames/"+anim+"/frame_"+str(i)+".png")
						obj.get_node("sprites").get_sprite_frames().add_frame(anim,sprite)
				
				if project[item]['group'] != "":
					groups.append(project[item]['group'])
					obj.set_name(project[item]['group'])
			else:
				obj = get_node(project[item]['group']).duplicate()
			
			obj.gg_set_animation(project[item]['anim'])
			obj.gg_set_frame(project[item]['frame'])
			obj.set_position(Vector2(project[item]['pos_x'],project[item]['pos_y']))
				
			add_child(obj)

func _on_back_button_down():
	get_tree().change_scene("res://main.tscn")
