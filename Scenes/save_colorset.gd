extends Button

func _on_button_down() -> void:
	get_node("/root/Node2D").outputColorset()
