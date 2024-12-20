extends LineEdit

func _on_text_submitted(new_text: String) -> void:
	get_node("/root/Node2D").updateMaxAmount(int(new_text))
	release_focus()
