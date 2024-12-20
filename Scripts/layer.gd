class_name Layer extends Node

var alternateList: Array[Alternate]
var ID
var overlay:bool = false
var overlayAmount:int = 0
var repeatAmount:int = 0
var extraAmount:int = 0
var maxAmount:int = 0

func _init(id = null, Overlay = false, OverlayAmount = 0, RepeatAmount = 0, ExtraAmount = 0, MaxAmount = 0):
	ID = id
	overlay = Overlay
	overlayAmount = OverlayAmount
	repeatAmount = RepeatAmount
	extraAmount = ExtraAmount
	maxAmount = MaxAmount
