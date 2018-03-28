extends TextureButton

var clicked = false
var location = ""
onready var main = get_node("/root/main")

func _ready():
	pass

func _on_item_button_down():
	if clicked:
		main._on_insert_into_scene_button_down()
	else:
		main.grid_clear_selection()
		main.item_location = location
		$selection.set_visible(true)
		clicked = true
