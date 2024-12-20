extends ColorPicker


func _on_color_changed(color: Color) -> void:
	get_node("/root/Node2D").changeColor(color)
