extends CheckButton

func _on_toggled(toggled_on: bool) -> void:
	get_node("/root/Node2D").toggleOverlayEnabled(toggled_on)
	release_focus()