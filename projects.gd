extends Node2D

var dir = Directory.new()
var file = File.new()
var config = ConfigFile.new()
onready var projects = $projects_list

func _ready():
	if dir.open("user://") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir() and file_name.substr(0,1) != ".":
				$projects_list.add_item(file_name)
			file_name = dir.get_next()
		_on_projects_list_item_selected(0)
		
		

func _on_projects_list_item_selected(index):
	global.project = projects.get_item_text(index)


func _on_btn_run_button_down():
	get_tree().change_scene("res://runner.tscn")


func _on_btn_edit_button_down():
	get_tree().change_scene("res://main.tscn")


func _on_btn_create_button_down():
	#TODO remove special characters and sanitize
	#TODO check if dir exists
	var name = $lne_name.get_text()
	dir.make_dir("user://"+name)
	file.open("user://"+name+"/scn_main.json", File.WRITE)
	file.store_line("{}")
	file.close()
	$projects_list.add_item(name)
