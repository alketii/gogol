extends Node2D

var project

onready var window_size = OS.get_screen_size()

onready var scroll = $TabContainer/Editor/ScrollContainer
onready var cnt = $TabContainer/Editor/ScrollContainer/Container
onready var objs = $TabContainer/Editor/ScrollContainer/Container/objs
onready var toolbox = $toolbox/VBoxContainer
onready var cats = $pop_add_object/WindowDialog/categories
onready var items_grid = $pop_add_object/WindowDialog/items_grid
onready var gviewport = cnt.get_node("viewport")
onready var dup_cnt = $duplicate_object/WindowDialog/VBoxContainer
onready var apply = $toolbox/VBoxContainer/apply

onready var newevent = $new_event_first/WindowDialog

#props
onready var prop_label = preload("res://object_props/Label.tscn")
onready var prop_spinbox = preload("res://object_props/SpinBox.tscn")
onready var prop_checkbutton = preload("res://object_props/CheckButton.tscn")
onready var prop_optionbutton = preload("res://object_props/OptionButton.tscn")

const obj = preload("res://obj.tscn")
const item = preload("res://item.tscn")

var item_location = ""

var obj_selected = ""
var pos = Vector2(0,0)

var groups = []
var obj_unique_list = []

var dir = Directory.new()
var file = File.new()
var config = ConfigFile.new()

var special_cond = ['Scene','Timer','Mouse & Keyboard']
var object_cond = ['Collides','Enters viewport','Leaves viewport','Compare X position','Compare Y position']

func _ready():
	#get_tree().change_scene("res://runner.tscn")
	OS.set_window_size(Vector2(1280,720))
	#OS.set_window_maximized(true)
	list_categories()
	window_resized()
	
	# TMP START
	for cond in special_cond:
		newevent.get_node("list_1").add_item(cond)

	# TMP END
	
	set_process_input(true)

func _input(event):
	if event is InputEventMouseMotion:
		pos = Vector2(event.position.x+scroll.get_h_scroll()-200,event.position.y+scroll.get_v_scroll()-27)
		$position.set_text(str(pos.x-gviewport.get_position().x)+","+str(pos.y-gviewport.get_position().y))

func selection_clear():
	#_on_apply_button_down()
	for i in objs.get_children():
		i.unselect()
	redraw_toolbox(false)

func selection_obj():
	var sobj = objs.get_node(obj_selected)
	redraw_toolbox(true)
	var new_prop

	for prop in sobj.custom_prop:
		var cprop = sobj.custom_prop[prop]
		if cprop['type'] == 'number':
			new_prop = prop_spinbox.instance()
			new_prop.set_name("prop_"+prop)
			new_prop.set_prefix(cprop['title'])
			new_prop.set_value(int(cprop['value']))
			new_prop.set_min(int(cprop['min']))
			new_prop.set_max(int(cprop['max']))
		
		elif cprop['type'] == 'toggle':
			new_prop = prop_checkbutton.instance()
			new_prop.set_name("prop_"+prop)
			new_prop.set_text(cprop['title'])
			if cprop['value'] == true:
				new_prop.set_pressed(true)
		
		elif cprop['type'] == 'options':
			new_prop = prop_optionbutton.instance()
			new_prop.set_name("prop_"+prop)
			for opt in cprop['options']:
				new_prop.add_item(opt)
			new_prop.set_text(cprop['value'])
			
		toolbox.add_child(new_prop)
	
	if sobj.custom_prop.size() == 0:
		toolbox.get_node("lbl_prop_custom").set_visible(false)
	
	toolbox.get_node("created_on_start").set_pressed(sobj.created_on_start)
	
	toolbox.get_node("obj_anim").clear()
	for a in sobj.anims:
		toolbox.get_node("obj_anim").add_item(a)
	
	toolbox.get_node("obj_frame").set_value(sobj.obj_frame)
	
	toolbox.move_child(toolbox.get_node("apply"),toolbox.get_child_count())

func redraw_toolbox(is_obj):
	for i in toolbox.get_children():
		if i.is_in_group("objects"):
			i.set_visible(is_obj)
		elif i.is_in_group("general"):
			i.set_visible(!is_obj)
		elif i.is_in_group("prop_custom"):
			i.free()
		
func _enter_tree():
    get_tree().get_root().connect("size_changed", self, "window_resized")

func window_resized():
	window_size = OS.get_window_size() - Vector2(205,35)
	$TabContainer.set_custom_minimum_size(window_size)
	scroll.set_custom_minimum_size(window_size)
	scroll.set_size(window_size)
	$toolbox.set_custom_minimum_size(Vector2(180,window_size.y/2))
	toolbox.set_custom_minimum_size(Vector2(180,window_size.y/2-20))
	gviewport.set_position(cnt.get_rect().size / Vector2(2,2) - gviewport.get_rect().size / Vector2(2,2))

func _on_focus_viewport_timeout():
	var gview_diff = (scroll.get_rect().size-gviewport.get_rect().size)/2
	scroll.set_h_scroll(gviewport.get_position().x-gview_diff.x)
	scroll.set_v_scroll(gviewport.get_position().y-gview_diff.y)
	read_project()

func list_categories():
	var dir = Directory.new()
	if dir.open("res://objects") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir() and file_name.substr(0,1) != ".":
				cats.add_item(file_name)
			file_name = dir.get_next()
	_on_categories_item_selected(0)

func _on_add_object_button_down():
	$pop_add_object/WindowDialog.popup()

func _on_insert_into_scene_button_down(pos=Vector2(32,32),animation="default",frame=1,inserted=false,group="",is_group=false,custom_props={},obj_name=""):
	# TODO refactor everything
	var obj_new = obj.instance()
	obj_new.location = item_location

	if inserted:
		obj_new.set_position(gviewport.get_position()+pos)
		obj_new.inserted = true
		obj_new.set_name(obj_name)
	else:
		obj_new.set_position(Vector2(scroll.get_h_scroll(),scroll.get_v_scroll())+pos)
		
	if config.load(item_location+"/config.ini") == OK:
		obj_new.obj_name = config.get_value("general","title","Object")
		obj_new.obj_type = config.get_value("general","type","static")

	if dir.file_exists("res://object_types/"+obj_new.obj_type+"/config.json"):
		file.open("res://object_types/"+obj_new.obj_type+"/config.json", file.READ)
		var jtext = parse_json(file.get_as_text())
		file.close()
		if inserted:
			for prop in custom_props:
				jtext[prop]["value"] = custom_props[prop]
		obj_new.init_prop(jtext)
	
	if dir.open(item_location+"/frames/") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir() and file_name.substr(0,1) != "." and file_name != "default":
				obj_new.anims.append(file_name)
			file_name = dir.get_next()
	
	obj_new.insert_into_list = !is_group
	obj_new.obj_is_group = is_group
	obj_new.obj_group = group
	obj_new.obj_frame = frame
	obj_new.obj_anim = animation
	objs.add_child(obj_new)
	obj_new.selected()
	$pop_add_object/WindowDialog.hide()

func _on_popup_close_button_down():
	$pop_add_object/WindowDialog.hide()
	
func grid_clear_selection():
	for i in items_grid.get_children():
		i.get_node("selection").set_visible(false)
		i.clicked = false

func _on_categories_item_selected(index):
	for i in items_grid.get_children():
		i.free()
	if dir.open("res://objects/"+cats.get_item_text(index)) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir() and file_name.substr(0,1) != ".":
				var item_icon = ImageTexture.new()
				item_icon = load("res://objects/"+cats.get_item_text(index)+"/"+file_name+"/icon_64.png")
				var item_new = item.instance()
				item_new.get_node("tile").set_texture(item_icon)
				item_new.location = "res://objects/"+cats.get_item_text(index)+"/"+file_name
				items_grid.add_child(item_new)
			file_name = dir.get_next()

func _on_editor_unselect_button_down():
	selection_clear()


func _on_save_project_button_down():
	#_on_apply_button_down()
	var output = {}
	if not dir.dir_exists("user://"+global.project):
		dir.make_dir("user://"+global.project)
	file.open("user://"+global.project+"/scn_"+global.scene+".json", File.WRITE)
	
	for i in objs.get_children():
		var props = {}
		for prop in i.custom_prop:
			props[prop] = i.custom_prop[prop]['value']
		
		var out_pos = i.get_position() - gviewport.get_position()
		output[i.get_name()]= {
			"name":i.obj_name,
			"pos_x":out_pos.x,
			"pos_y":out_pos.y,
			"type":i.obj_type,
			"loc":i.location,
			"group":i.obj_group,
			"anim":i.obj_anim,
			"frame":i.obj_frame,
			"prop":props
		}
	file.store_line(to_json(output))
	file.close()
	get_tree().change_scene("res://runner.tscn")

func _on_duplicate_object_button_down():
	dup_cnt.get_node("clone").set_pressed(false)
	dup_cnt.get_node("cols").set_value(2)
	dup_cnt.get_node("rows").set_value(1)
	dup_cnt.get_node("horizontal").set_value(0)
	dup_cnt.get_node("vertical").set_value(0)
	_on_duplicate_value_changed(0)
	objs.get_node(obj_selected+"/duplicate_sel").set_visible(true)
	$duplicate_object/WindowDialog.popup()


func _on_duplicate_button_down():
	var clone = dup_cnt.get_node("clone").is_pressed()
	var cols = dup_cnt.get_node("cols").get_value()
	var rows = dup_cnt.get_node("rows").get_value()
	var spacing = Vector2(dup_cnt.get_node("horizontal").get_value(),dup_cnt.get_node("vertical").get_value())
	var obj_group = ""
	var d_obj = objs.get_node(obj_selected)
	if d_obj.obj_group == "":
		obj_group = "grp_"+str(OS.get_unix_time()) #to be replaced by proper id
		d_obj.obj_group = obj_group
	else:
		obj_group = d_obj.obj_group
	
	for x in range(1,cols+1):
		for y in range(1,rows+1):
			if Vector2(x,y) != Vector2(1,1):
				# TODO old code, this should be done by _on_insert_into_scene_button_down()
				var d_obj_new = obj.instance()
				if not clone:
					d_obj_new.obj_group = obj_group
					d_obj_new.obj_is_group = true
				d_obj_new.location = d_obj.location
				d_obj_new.obj_anim = d_obj.obj_anim
				d_obj_new.obj_frame = d_obj.obj_frame
				d_obj_new.custom_prop = d_obj.custom_prop
				d_obj_new.set_position(d_obj.get_position()+(d_obj.get_size()+spacing)*Vector2(x-1,y-1))
				objs.add_child(d_obj_new)
				
	$duplicate_object/WindowDialog.hide()
	

func _on_duplicate_value_changed(value):
	var cols = dup_cnt.get_node("cols").get_value()
	var rows = dup_cnt.get_node("rows").get_value()
	var c_space = dup_cnt.get_node("horizontal").get_value()
	var r_space = dup_cnt.get_node("vertical").get_value()
	var tile_size = objs.get_node(obj_selected).get_size()
	
	objs.get_node(obj_selected+"/duplicate_sel").set_size(Vector2(tile_size.x*cols+c_space*cols,tile_size.y*rows+r_space*rows))


#duplicate window
func _on_WindowDialog_popup_hide():
	objs.get_node(obj_selected+"/duplicate_sel").set_visible(false)


func _on_scenes_button_down():
	$scenes/WindowDialog.popup()

func _on_remove_object_button_down():
	$confirm_remove/confirm_remove.popup()

func _on_confirm_remove_confirmed():
	objs.get_node(obj_selected).free()
	selection_clear()

func _on_apply_button_down():
	#objs.get_node(obj_selected).obj_name = toolbox.get_node("obj_name").get_text()
	for i in toolbox.get_children():
		if i.is_in_group("prop_custom"):
			var prop = i.get_name().right(5)
			var value = 0
			if i is CheckButton:
				value = i.is_pressed()
			elif i is OptionButton:
				value = i.get_text()
			else:
				value = i.get_value()

			objs.get_node(obj_selected).custom_prop[prop]['value'] = value

func _on_obj_anim_item_selected(index):
	var anim = toolbox.get_node("obj_anim").get_item_text(index)
	objs.get_node(obj_selected).obj_anim = anim
	toolbox.get_node("obj_frame").set_value(1)
	objs.get_node(obj_selected).update_anim()
	limit_frames()


func _on_obj_frame_value_changed(frame):
	objs.get_node(obj_selected).obj_frame = frame
	objs.get_node(obj_selected).update_anim()

func limit_frames():
	var frames = 0
	var anim = toolbox.get_node("obj_anim").get_item_text(toolbox.get_node("obj_anim").get_selected_id())
	if dir.open(objs.get_node(obj_selected).location+"/frames/"+anim+"/") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if file_name.substr(0,6) == "frame_" and file_name.substr(file_name.length()-4,file_name.length()) == ".png":
				frames += 1
			file_name = dir.get_next()
		toolbox.get_node("obj_frame").set_max(frames)

func _on_created_on_start_toggled(state):
	objs.get_node(obj_selected).created_on_start(state)


func _on_obj_list_item_selected(index):
	# TODO different approach
	objs.get_node(obj_unique_list[index]).selected()
	
func read_project():
	file.open("user://"+global.project+"/scn_"+global.scene+".json", File.READ)
	project = parse_json(file.get_as_text())
	file.close()
	var unique = false
	for item in project:
		var is_group = false

		if project[item]['group'] != "":
			if groups.find(project[item]['group']) == -1:
				groups.append(project[item]['group'])
			else:
				is_group = true
		item_location = project[item]['loc']
		_on_insert_into_scene_button_down(Vector2(project[item]['pos_x'],project[item]['pos_y']),project[item]['anim'],project[item]['frame'],true,project[item]['group'],is_group,project[item]['prop'],item)
	
	selection_clear()

func _on_btn_projects_button_down():
	get_tree().change_scene("res://projects.tscn")


func _on_new_event_button_down():

	$new_event_first/WindowDialog.popup()


func _on_list_1_item_selected(index):
	newevent.get_node("list_2").clear()
	var conds = []
	if index >= special_cond.size():
		conds = object_cond
	
	for cond in conds:
		newevent.get_node("list_2").add_item(cond)
