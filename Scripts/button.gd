extends Button
@export
var layer:int = -1
var alternate:int = -1
var color:int = -1

func setData(l:int, a:int, c:int):
	layer = l
	alternate = a
	color = c

func _on_button_down() -> void:
	#breakpoint
	get_node("/root/Node2D").selectObject(layer, alternate, color)
