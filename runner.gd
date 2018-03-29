extends Node2D

var project = {}

func _ready():
	var file = File.new()
	file.open("user://"+global.project+"/scn_"+global.scene+".json", File.READ)
	project = parse_json(file.get_as_text())
	file.close()
	for item in project:
		if project[item]['type'] == "static": # TMP only allow static for now
			var obj_load = load("res://object_types/"+project[item]['type']+"/obj.tscn") #for some reason item['loc'] is not working
			var obj = obj_load.instance()
			obj.set_position(Vector2(project[item]['pos_x'],project[item]['pos_y']))
			obj.gg_import_media(project[item]['loc']) # TODO if obj is part of a group, just skip this part and clone the node
			obj.gg_set_animation(project[item]['anim'])
			obj.gg_set_frame(project[item]['frame'])
			add_child(obj)

func _on_back_button_down():
	get_tree().change_scene("res://main.tscn")
