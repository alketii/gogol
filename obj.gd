extends TextureButton

onready var main = get_node("/root/main")
var pos = Vector2(0,0)
var obj_name = "Object"
var obj_id = "0"
var obj_type = "static"
var obj_is_group = false
var obj_group = ""
var obj_anim = "default"
var obj_frame = 1

var dragging = false
var selected = false

var tile = ImageTexture.new()
var icon = ImageTexture.new()

var location = ""
var custom_prop = {}
var anims = ['default']
var created_on_start = true

func _ready():
	var id = str(main.objs.get_child_count()) # TODO repleace by proper ID
	obj_id = "obj_"+id
	obj_name += " "+id
	set_name(obj_id)

	update_anim()
	
	if obj_group == "" or not obj_is_group:
		icon.load(location+"/icon_24.png")
		main.get_node("obj_list").add_item(obj_name,icon)
		
	set_process(true)

func init_prop(json):
	custom_prop = json

func _on_obj_button_down():
	pos = main.pos - get_position()
	dragging = true
	if not selected:
		selected()

func _on_obj_button_up():
	dragging = false

func _process(delta):
	if dragging:
		set_position(main.pos-pos)

func selected():
	main.selection_clear()
	main.toolbox.get_node("obj_name").set_text(obj_name)
	main.obj_selected = get_name()
	$selection.set_visible(true)
	selected = true
	main.selection_obj()

func unselect():
	$selection.set_visible(false)
	selected = false
	
func update_anim():
	tile = load(location+"/frames/"+obj_anim+"/frame_"+str(obj_frame)+".png")
	$tile.set_texture(tile)
	
	var size = tile.get_size()
	
	self.set_size(size)
	$selection.set_size(size)

func created_on_start(state):
	created_on_start = state
	set_visible(created_on_start)