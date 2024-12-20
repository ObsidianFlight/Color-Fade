extends Camera2D

var view

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	view = get_viewport()
	
func _process(delta: float) -> void:
	offset = view.get_visible_rect().size/2
