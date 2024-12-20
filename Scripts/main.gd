extends Node2D
var scene = load("res://Scenes/Button.tscn")
var settings = load("res://Scenes/Settings.tscn")
var colorSettings = load("res://Scenes/ColorSettings.tscn")
var alternateSettings = load("res://Scenes/AlternateSettings.tscn")
var layerSettings = load("res://Scenes/LayerSettings.tscn")
var colorObject = load("res://Scenes/colorObject.tscn")

var layerContainer: VBoxContainer
var alternateContainer: VBoxContainer
var colorContainer: VBoxContainer

var controlPanel: Panel

var alternateInContainer: Array[Button]
var colorInContainer: Array[Button]

var layerAdd: Button
var alternateAdd: Button
var colorAdd: Button

var copy
var layerList: Array[Layer]
var selectedObject: Array[int]

var visibleColorList: Array[Color]
var finalLayerList: Array[Layer]

var showFinal: bool = true
var separation: int = 26
var outline: bool = true
var extras: bool = false
var outputType: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in 3:
		selectedObject.append(-1)
	controlPanel = $"Control/ControlPanel"
	layerContainer = $"Control/LayerPanel/ScrollContainer/VBoxContainer"
	alternateContainer = $"Control/AlternatesPanel/ScrollContainer/VBoxContainer"
	colorContainer = $"Control/ColorPanel/ScrollContainer/VBoxContainer"
	layerAdd = $"Control/LayerPanel/ScrollContainer/VBoxContainer/LayerAdd"
	alternateAdd = $"Control/AlternatesPanel/ScrollContainer/VBoxContainer/AlternateAdd"
	colorAdd = $"Control/ColorPanel/ScrollContainer/VBoxContainer/ColorAdd"

func _unhandled_input(event) -> void:
	if Input.is_action_just_pressed("MoveUp"):
		if selectedObject[2] == -1: #Not a color
			if selectedObject[1] == -1: #Not an alternate
				if selectedObject[0] == -1: #Not a layer
					return
				else:
					if selectedObject[0] == 0:
						return #Can't move first layer up
					else:
						var first = layerList[selectedObject[0]]
						first.ID -= 1
						var second = layerList[selectedObject[0]-1]
						second.ID += 1
						layerList[selectedObject[0]] = second
						layerList[selectedObject[0]-1] = first
						selectObject(selectedObject[0]-1, -1, -1)
						if showFinal:
							updateVisibleColors()
			else:
				if selectedObject[1] == 0:
					return #Can't move first alternate up
				else:
					var first = layerList[selectedObject[0]].alternateList[selectedObject[1]]
					first.ID -= 1
					var second = layerList[selectedObject[0]].alternateList[selectedObject[1]-1]
					second.ID += 1
					layerList[selectedObject[0]].alternateList[selectedObject[1]] = second
					layerList[selectedObject[0]].alternateList[selectedObject[1]-1] = first
					selectObject(selectedObject[0], selectedObject[1]-1, -1)
					if showFinal:
						updateVisibleColors()
		else: #Is a color
			if selectedObject[2] == 0:
				return #Can't move first color up
			else:
				var first = layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList[selectedObject[2]]
				var second = layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList[selectedObject[2]-1]
				layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList[selectedObject[2]] = second
				layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList[selectedObject[2]-1] = first
				selectObject(selectedObject[0], selectedObject[1], selectedObject[2]-1)
				if showFinal:
					updateVisibleColors()
	
	if Input.is_action_just_pressed("MoveDown"):
		if selectedObject[2] == -1: #Not a color
			if selectedObject[1] == -1: #Not an alternate
				if selectedObject[0] == -1: #Not a layer
					return
				else:
					if selectedObject[0] == layerList.size()-1:
						return #Can't move last layer down
					else:
						var first = layerList[selectedObject[0]]
						first.ID += 1
						var second = layerList[selectedObject[0]+1]
						second.ID -= 1
						layerList[selectedObject[0]] = second
						layerList[selectedObject[0]+1] = first
						selectObject(selectedObject[0]+1, -1, -1)
						if showFinal:
							updateVisibleColors()
			else:
				if selectedObject[1] == layerList[selectedObject[0]].alternateList.size()-1:
					return #Can't move last alternate down
				else:
					var first = layerList[selectedObject[0]].alternateList[selectedObject[1]]
					first.ID += 1
					var second = layerList[selectedObject[0]].alternateList[selectedObject[1]+1]
					second.ID -= 1
					layerList[selectedObject[0]].alternateList[selectedObject[1]] = second
					layerList[selectedObject[0]].alternateList[selectedObject[1]+1] = first
					selectObject(selectedObject[0], selectedObject[1]+1, -1)
					if showFinal:
						updateVisibleColors()
		else: #Is a color
			if selectedObject[2] == layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList.size()-1:
				return #Can't move last color down
			else:
				var first = layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList[selectedObject[2]]
				var second = layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList[selectedObject[2] + 1]
				layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList[selectedObject[2]] = second
				layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList[selectedObject[2]+1] = first
				selectObject(selectedObject[0], selectedObject[1], selectedObject[2]+1)
				if showFinal:
					updateVisibleColors()
	
	if Input.is_action_just_pressed("Copy"):
		if selectedObject[2] != -1:
			copy = layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList[selectedObject[2]]
		else: if selectedObject[1] != -1:
			copy = layerList[selectedObject[0]].alternateList[selectedObject[1]]
		else: if selectedObject[0] != -1:
			copy = layerList[selectedObject[0]]
	
	if Input.is_action_just_pressed("Paste"):
		if selectedObject[2] != -1:
			if copy is Color:
				var instance = scene.instantiate()
				instance.setData(selectedObject[0], selectedObject[1], selectedObject[2]+1)
				for i in colorContainer.get_children().size() -1:
					var j = colorContainer.get_child(i)
					if j.color >= selectedObject[2]+1:
						j.color += 1
				colorContainer.add_child(instance)
				colorContainer.move_child(instance, selectedObject[2]+1)
				colorInContainer.insert(selectedObject[2]+1, instance)
				instance.get_child(0).get_child(0).visible = true
				layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList.insert(selectedObject[2]+1, copy)
				selectObject(selectedObject[0], selectedObject[1], selectedObject[2]+1)
		else: if selectedObject[1] != -1:
			if copy is Alternate:
				var new = copy.duplicate()
				new.ID = selectedObject[1]+1
				new.fadeLength = copy.fadeLength
				new.colorList = copy.colorList.duplicate()
				var instance = scene.instantiate()
				instance.setData(selectedObject[0], selectedObject[1]+1, -1)
				for i in alternateContainer.get_children().size() -1:
					var j = alternateContainer.get_child(i)
					if j.alternate >= selectedObject[1]+1:
						j.alternate += 1
				alternateContainer.add_child(instance)
				alternateContainer.move_child(instance, selectedObject[1]+1)
				alternateInContainer.insert(selectedObject[1]+1, instance)
				layerList[selectedObject[0]].alternateList.insert(selectedObject[1]+1, new)
				for i in layerList[selectedObject[0]].alternateList:
					if i.ID > selectedObject[1]+1:
						i.ID += 1
				selectObject(selectedObject[0], selectedObject[1]+1, -1)
		else: if selectedObject[0] != -1:
			if copy is Layer:
				var new = copy.duplicate()
				new.ID = selectedObject[0]+1
				new.overlay = copy.overlay
				new.overlayAmount = copy.overlayAmount
				new.repeatAmount = copy.repeatAmount
				new.extraAmount = copy.extraAmount
				new.maxAmount = copy.maxAmount
				for i in copy.alternateList:
					var newAlternate = Alternate.new(i.ID)
					newAlternate.colorList = i.colorList.duplicate()
					newAlternate.fadeLength = i.fadeLength
					new.alternateList.append(newAlternate)
				var instance = scene.instantiate()
				instance.setData(selectedObject[0]+1, -1, -1)
				for i in layerContainer.get_children().size() -1:
					var j = layerContainer.get_child(i)
					if j.layer >= selectedObject[0]+1:
						j.layer += 1
				layerContainer.add_child(instance)
				layerContainer.move_child(instance, selectedObject[0]+1)
				layerList.insert(selectedObject[0]+1, new)
				for i in layerList:
					if i.ID > selectedObject[0]+1:
						i.ID += 1
				selectObject(selectedObject[0]+1, -1, -1)
				
		if showFinal:
			updateVisibleColors()
	
	if Input.is_action_just_pressed("Delete"):
		if selectedObject[2] == -1: #Not a color
			if selectedObject[1] == -1: #Not an alternate
				if selectedObject[0] == -1: #Not a layer, can't delete
					return
				else: #Is a layer
					layerList.remove_at(selectedObject[0])
					for i in layerList:
						if i.ID > selectedObject[0]:
							i.ID -= 1
					var toDelete = layerContainer.get_child(selectedObject[0])
					layerContainer.remove_child(toDelete)
					for i in layerContainer.get_children().size() -1:
						var j = layerContainer.get_child(i)
						if j.layer > selectedObject[0]:
							j.layer -= 1
					toDelete.free()
			else: #Is an alternate
				layerList[selectedObject[0]].alternateList.remove_at(selectedObject[1])
				for i in layerList[selectedObject[0]].alternateList:
					if i.ID > selectedObject[1]:
						i.ID -= 1
				var toDelete = alternateInContainer[selectedObject[1]]
				alternateInContainer.erase(toDelete)
				alternateContainer.remove_child(toDelete)
				for i in alternateContainer.get_children().size() -1:
					var j = alternateContainer.get_child(i)
					if j.alternate > selectedObject[1]:
						j.alternate -= 1
				toDelete.free()
		else: #Is a color
			layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList.remove_at(selectedObject[2])
			var toDelete = colorInContainer[selectedObject[2]]
			colorInContainer.erase(toDelete)
			colorContainer.remove_child(toDelete)
			for i in colorContainer.get_children().size() -1:
				var j = colorContainer.get_child(i)
				if j.color > selectedObject[2]:
					j.color -= 1
			toDelete.free()
		
		if colorContainer.get_children().size()-1 == selectedObject[2]:
			selectedObject[2] -= 1
		if alternateContainer.get_children().size()-1 == selectedObject[1]:
			selectedObject[1] -= 1
		if layerContainer.get_children().size()-1 == selectedObject[0]:
			selectedObject[0] -= 1
		selectObject(selectedObject[0], selectedObject[1], selectedObject[2])
		if showFinal:
			updateVisibleColors()

func _on_layer_add_button_down() -> void:
	addObject(0, false, true)
	selectObject(layerContainer.get_child_count()-2, -1, -1)

func _on_alternate_add_button_down() -> void:
	addObject(1, false, true)
	selectObject(selectedObject[0], alternateContainer.get_child_count()-2, -1)

func _on_color_add_button_down() -> void:
	addObject(2, false, true, selectedObject[1])
	selectObject(selectedObject[0], selectedObject[1], colorContainer.get_child_count()-2)

func selectObject(layer: int, alternate: int, color:int):
	deselectObject(selectedObject[0], selectedObject[1], selectedObject[2])
	selectedObject[0] = layer
	selectedObject[1] = alternate
	selectedObject[2] = color
	
	alternateAdd.visible = false
	colorAdd.visible = false
	
	if color == -1: #If not a color
		if alternate == -1: # If not an alternate
			if layer == -1: # If settings
				loadOptions(0)
				loadLayerTree(0)
				setPanelColor(-1, -1, -1, 0, 255, 255)
			else: #If layer
				loadLayerTree(0)
				loadOptions(1)
				setPanelColor(layer, -1, -1, 0, 255, 255)
				alternateAdd.visible = true
		else: # If alternate
			loadLayerTree(1)
			loadOptions(2)
			setPanelColor(layer, -1, -1, 255, 255, 0)
			setPanelColor(layer, alternate, -1, 0, 255, 255)
			alternateAdd.visible = true
			colorAdd.visible = true
	else: # If Color
		for i in colorInContainer:
			if i.alternate != selectedObject[1]:
				i.free()
		colorInContainer.clear()
		for i in layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList.size():
			colorInContainer.append(colorContainer.get_child(i))
		for i in layerList[selectedObject[0]].alternateList.size():
			alternateContainer.get_child(i).text = ""
		for i in layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList.size():
			colorContainer.get_child(i).text = ""
		loadOptions(3)
		setPanelColor(layer, -1, -1, 255, 255, 0)
		setPanelColor(layer, alternate, -1, 255, 255, 0)
		setPanelColor(layer, alternate, color, 0, 255, 255)
		alternateAdd.visible = true
		colorAdd.visible = true
	updateTreeColor()
	if !showFinal:
		updateVisibleColors()

func deselectObject(layer: int, alternate: int, color:int):
	setPanelColor(layer, -1, -1, 255, 255, 255)
	setPanelColor(layer, alternate, -1, 255, 255, 255)
	setPanelColor(layer, alternate, color, 255, 255, 255)

func setPanelColor(layer:int, alternate:int, color:int, r:int, g:int, b:int):
	if layer != -1:
		if alternate == -1: # If selecting a Layer
			layerContainer.get_child(layer).get_child(0).get_theme_stylebox("panel").modulate_color = Color8(r, g, b)
		else: # If selecting alternate or color
			if color == -1: # If selecting alternate
				alternateContainer.get_child(alternate).get_child(0).get_theme_stylebox("panel").modulate_color = Color8(r, g, b)
			else:
				colorContainer.get_child(color).get_child(0).get_theme_stylebox("panel").modulate_color = Color8(r, g, b)
	if layer == -1:
		$"Control/Options".get_child(0).get_theme_stylebox("panel").modulate_color = Color8(r, g, b)

func loadLayerTree(depth:int):
	if depth == 0:
		for i in alternateInContainer.size():
			alternateContainer.get_child(0).free()
		for i in colorInContainer.size():
			colorContainer.get_child(0).free()
		alternateInContainer.clear()
		colorInContainer.clear()
	if depth == 1:
		for i in colorInContainer.size():
			colorContainer.get_child(0).free()
		colorInContainer.clear()
	if selectedObject[0] != -1: #Select Layer
		if selectedObject[1] != -1: #Select Alternate
			for i in layerList[selectedObject[0]].alternateList.size():
				alternateContainer.get_child(i).text = ""
			for i in layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList:
				addObject(2, false, false)
			if selectedObject[2] != -1: #Select Color
				for i in layerList[selectedObject[0]].alternateList.size():
					alternateContainer.get_child(i).text = ""
					for j in layerList[selectedObject[0]].alternateList[i].colorList.size():
						colorContainer.get_child(j).text = ""
		else: #Selected layer
			var currentAlternate = 0
			for i in layerList[selectedObject[0]].alternateList:
				addObject(1, true, false, currentAlternate)
				for j in i.colorList:
					addObject(2, true, false, currentAlternate)
				currentAlternate += 1

func addObject(type:int, showPosition:bool, new:bool = false, currentAlternate:int = selectedObject[1]):
	var instance = scene.instantiate()
	if showPosition:
		instance.text = str(currentAlternate)
	else:
		instance.text = ""
	if type == 0:
		var childCount = layerContainer.get_child_count()-1
		instance.setData(childCount, selectedObject[1], selectedObject[2])
		layerContainer.add_child(instance)
		layerContainer.move_child(instance, childCount)
		if new:
			layerList.append(Layer.new(childCount))
			instance.setData(childCount, -1, -1)
	else: if type == 1:
		var childCount = alternateContainer.get_child_count()-1
		instance.setData(selectedObject[0], childCount, selectedObject[2])
		alternateContainer.add_child(instance)
		alternateContainer.move_child(instance, childCount)
		alternateInContainer.append(instance)
		if new:
			layerList[selectedObject[0]].alternateList.append(Alternate.new(childCount))
			instance.setData(selectedObject[0], childCount, -1)
	else: if type == 2:
		var childCount = colorContainer.get_child_count()-1
		if selectedObject[1] == -1:
			var totalCount = 0
			for i in layerList[selectedObject[0]].alternateList:
				totalCount += i.colorList.size()
				if i.ID == currentAlternate:
					var colorCount = i.colorList.size()
					instance.setData(selectedObject[0], currentAlternate, colorCount+childCount-totalCount)
		else:
			instance.setData(selectedObject[0], currentAlternate, childCount)
		colorContainer.add_child(instance)
		colorContainer.move_child(instance, childCount)
		colorInContainer.append(instance)
		instance.get_child(0).get_child(0).visible = true
		if new:
			layerList[selectedObject[0]].alternateList[currentAlternate].colorList.append(Color8(255, 255, 255))
		else:
			pass
	updateVisibleColors()

func loadOptions(type:int):
	for i in controlPanel.get_children():
		i.free()
	if type == 0: #Settings
		print("load settings")
		var instance = settings.instantiate()
		controlPanel.add_child(instance)
		instance.get_child(0).get_child(1).button_pressed = showFinal
		instance.get_child(2).get_child(0).button_pressed = outline
		instance.get_child(5).text = str(separation)
		instance.get_child(8).text = str(outputType)
		instance.get_child(10).get_child(0).button_pressed = extras
	if type == 1: #Layer
		print("load layer " + str(selectedObject[0]) + " options.")
		var instance = layerSettings.instantiate()
		controlPanel.add_child(instance)
		instance.get_child(1).get_child(0).button_pressed = layerList[selectedObject[0]].overlay
		instance.get_child(1).get_child(1).text = str(layerList[selectedObject[0]].overlayAmount)
		instance.get_child(4).text = str(layerList[selectedObject[0]].repeatAmount)
		instance.get_child(7).text = str(layerList[selectedObject[0]].extraAmount)
		instance.get_child(10).text = str(layerList[selectedObject[0]].maxAmount)
	if type == 2: #Alternate
		print("load layer " + str(selectedObject[0]) + ", alternate " + str(selectedObject[1]) + " options.")
		var instance = alternateSettings.instantiate()
		controlPanel.add_child(instance)
		instance.get_child(1).text = str(layerList[selectedObject[0]].alternateList[selectedObject[1]].fadeLength)
	if type == 3: #Color
		print("load layer " + str(selectedObject[0]) + ", alternate " + str(selectedObject[1]) + ", color " + str(selectedObject[2]) + " options.")
		var instance = colorSettings.instantiate()
		controlPanel.add_child(instance)
		instance.get_child(0).get_child(0).color = layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList[selectedObject[2]]

func updateTreeColor():
	for i in colorContainer.get_children().size() -1:
		var j = colorContainer.get_child(i)
		j.get_child(0).get_child(0).color = layerList[j.layer].alternateList[j.alternate].colorList[j.color]

func changeColor(color:Color):
	layerList[selectedObject[0]].alternateList[selectedObject[1]].colorList[selectedObject[2]] = color
	colorContainer.get_child(selectedObject[2]).get_child(0).get_child(0).color = color
	updateVisibleColors()

func updateAlternateFadeLength(length:int):
	layerList[selectedObject[0]].alternateList[selectedObject[1]].fadeLength = length
	updateVisibleColors()

func updateOverlayAmount(amount:int):
	layerList[selectedObject[0]].overlayAmount = amount
	updateVisibleColors()

func toggleOverlayEnabled(toggle:bool):
	layerList[selectedObject[0]].overlay = toggle
	updateVisibleColors()

func updateRepeatAmount(amount:int):
	layerList[selectedObject[0]].repeatAmount = amount
	updateVisibleColors()

func updateExtraAmount(amount:int):
	layerList[selectedObject[0]].extraAmount = amount
	updateVisibleColors()

func updateMaxAmount(amount:int):
	layerList[selectedObject[0]].maxAmount = amount
	updateVisibleColors()

func toggleShowFinal(toggle:bool):
	if showFinal != toggle:
		showFinal = toggle
		updateVisibleColors()

func toggleOutline(toggle:bool):
	outline = toggle
	for i in $Control/ColorView/ScrollContainer/HBoxContainer.get_children():
		i.get_child(0).visible = toggle

func toggleExtras(toggle:bool):
	extras = toggle
	print(toggle)
	for i in $Control/ColorView/ScrollContainer/HBoxContainer.get_children():
		i.get_child(1).visible = toggle

func updateSeparation(amount:int):
	separation = amount
	$Control/ColorView/ScrollContainer/HBoxContainer.add_theme_constant_override("separation", separation)

func updateOutputType(type:int):
	outputType = type

func updateVisibleColors(recalculate:bool = true):
	finalLayerList.clear()
	visibleColorList.clear()
	var theChild = $Control/ColorView/ScrollContainer/HBoxContainer.get_children()
	var childAmount = theChild.size()
	for i in childAmount:
		theChild[i].queue_free()
	if layerList.size() == 0:
		return

	if recalculate:
		#First, set fades
		var skipLayer:int = 0
		var skipAlternate:int = 0
		for i in layerList.size():
			var cur = layerList[i]
			var hasColor:bool = false
			for k in layerList[i].alternateList:
				if k.colorList.size() != 0:
					hasColor = true
					print("has color")
			if(hasColor):
				finalLayerList.append(Layer.new(i, cur.overlay, cur.overlayAmount, cur.repeatAmount, cur.extraAmount, cur.maxAmount))
			else:
				skipLayer += 1
				print(skipLayer)
				continue
			for j in layerList[i].alternateList.size():
				if layerList[i].alternateList[j].colorList.size() == 0:
					skipAlternate += 1
					continue
				finalLayerList[i-skipLayer].alternateList.append(Alternate.new())
				print(str(i) + ", " + str(j))
				for k in layerList[i].alternateList[j].colorList.size():
					if layerList[i].alternateList[j].colorList.size() == 0:
						continue
					var color1 = Color.WHITE
					var color2 = Color.WHITE
					if k != layerList[i].alternateList[j].colorList.size() -1:
						color1 = layerList[i].alternateList[j].colorList[k]
						color2 = layerList[i].alternateList[j].colorList[k+1]
					else:
						color1 = layerList[i].alternateList[j].colorList[k]
						color2 = layerList[i].alternateList[j].colorList[0]
					finalLayerList[i-skipLayer].alternateList[j-skipAlternate].colorList.append_array(fadeColor(color1, color2, layerList[i].alternateList[j].fadeLength))
	
	#Second, weave the layer together
	var intermediateColorList: Array[Layer] #1 Alternate per layer, just used as color holders
	for i in finalLayerList.size():
		var cur = finalLayerList[i]
		intermediateColorList.append(Layer.new(i, cur.overlay, cur.overlayAmount, cur.repeatAmount, cur.extraAmount, cur.maxAmount))
		intermediateColorList[i].alternateList.append(Alternate.new(0))
		var alternateSize: Array[int]
		for j in finalLayerList[i].alternateList.size():
			if finalLayerList[i].alternateList[j].colorList.size() != 0:
				alternateSize.append(finalLayerList[i].alternateList[j].colorList.size())
		var LCM = lowestCommonMultiplierArray(alternateSize)
		if showFinal:
			for j in LCM*finalLayerList[i].alternateList.size():
				var currentAlternate = finalLayerList[i].alternateList[j%finalLayerList[i].alternateList.size()]
				intermediateColorList[i].alternateList[0].colorList.append(currentAlternate.colorList[int(floor(float(j)/finalLayerList[i].alternateList.size())) % currentAlternate.colorList.size()])
		else:
			if i == selectedObject[0]:
				if selectedObject[1] != -1:
					for j in finalLayerList[i].alternateList.size():
						if j == selectedObject[1]:
							if selectedObject[2] != -1:
								for k in layerList[i].alternateList[j].colorList.size():
									if k == selectedObject[2]:
										for l in layerList[i].alternateList[j].fadeLength+1:
											visibleColorList.append(finalLayerList[i].alternateList[j].colorList[k*(layerList[i].alternateList[j].fadeLength+1)+l])
							else:
								for k in finalLayerList[i].alternateList[j].colorList.size():
									visibleColorList.append(finalLayerList[i].alternateList[j].colorList[k])
				else:
					for j in LCM*finalLayerList[i].alternateList.size():
						var currentAlternate = finalLayerList[i].alternateList[j%finalLayerList[i].alternateList.size()]
						visibleColorList.append(currentAlternate.colorList[int(floor(float(j)/finalLayerList[i].alternateList.size())) % currentAlternate.colorList.size()])
	
	#Third, put layers on top of one another,
	#If layer is overlay, shift all colors by -overlayAmount on the layer
	var overlayColorList: Array[Layer] #Used to hold overlays
	var overlayColorListSkipped: int = 0
	var nonOverlayColorList: Array[Layer]
	var allColorAmount:int = 0
	for i in intermediateColorList.size():
		if intermediateColorList[i].maxAmount > 0:
			if intermediateColorList[i].alternateList[0].colorList.size() > intermediateColorList[i].maxAmount:
				for o in intermediateColorList[i].alternateList[0].colorList.size() - intermediateColorList[i].maxAmount:
					intermediateColorList[i].alternateList[0].colorList.pop_at(-1)
			else:
				var colors = intermediateColorList[i].alternateList[0].colorList.duplicate()
				var continueAdding:bool = true
				if intermediateColorList[i].repeatAmount > 0:
					for k in intermediateColorList[i].repeatAmount:
						if continueAdding:
							intermediateColorList[i].alternateList[0].colorList.append_array(colors)
							if intermediateColorList[i].alternateList[0].colorList.size() > intermediateColorList[i].maxAmount:
								continueAdding = false
								for o in intermediateColorList[i].alternateList[0].colorList.size() - intermediateColorList[i].maxAmount:
									intermediateColorList[i].alternateList[0].colorList.pop_at(-1)
				if intermediateColorList[i].extraAmount > 0 and continueAdding:
					for o in colors.size() - intermediateColorList[i].extraAmount:
						colors.pop_at(-1)
					intermediateColorList[i].alternateList[0].colorList.append_array(colors)
					if intermediateColorList[i].alternateList[0].colorList.size() > intermediateColorList[i].maxAmount:
						for o in intermediateColorList[i].alternateList[0].colorList.size() - intermediateColorList[i].maxAmount:
							intermediateColorList[i].alternateList[0].colorList.pop_at(-1)
		else:
			var colors = intermediateColorList[i].alternateList[0].colorList.duplicate()
			if intermediateColorList[i].repeatAmount > 0:
				for k in intermediateColorList[i].repeatAmount:
					intermediateColorList[i].alternateList[0].colorList.append_array(colors)
			if intermediateColorList[i].extraAmount > 0:
				for o in colors.size() - intermediateColorList[i].extraAmount:
					colors.pop_at(-1)
				intermediateColorList[i].alternateList[0].colorList.append_array(colors)
				
		if i == 0:
			allColorAmount += intermediateColorList[i].alternateList[0].colorList.size()
			visibleColorList.append_array(intermediateColorList[i].alternateList[0].colorList)
			overlayColorListSkipped += 1
		else:
			if intermediateColorList[i].overlay == false:
				overlayColorListSkipped += 1
				var colorAmount = intermediateColorList[i].alternateList[0].colorList.size()
				var overlayAmount = intermediateColorList[i].overlayAmount
				if overlayAmount > colorAmount:
					overlayAmount = colorAmount
				if overlayAmount > allColorAmount:
					overlayAmount = allColorAmount
				for j in colorAmount:
					var curNumber = j + allColorAmount - overlayAmount
					if curNumber > allColorAmount-1:
						visibleColorList.append(intermediateColorList[i].alternateList[0].colorList[j])
					else:
						var firstMix: Color = visibleColorList[curNumber]
						var secondMix: Color = intermediateColorList[i].alternateList[0].colorList[j]
						var R: float = ((firstMix.r / float(overlayAmount+1)) * float(overlayAmount - j)) + ((secondMix.r / float(overlayAmount+1)) * float(overlayAmount - (overlayAmount - (j+1))))
						var G: float = ((firstMix.g / float(overlayAmount+1)) * float(overlayAmount - j)) + ((secondMix.g / float(overlayAmount+1)) * float(overlayAmount - (overlayAmount - (j+1))))
						var B: float = ((firstMix.b / float(overlayAmount+1)) * float(overlayAmount - j)) + ((secondMix.b / float(overlayAmount+1)) * float(overlayAmount - (overlayAmount - (j+1))))
						visibleColorList[curNumber] = Color(R, G, B)
				allColorAmount += colorAmount - overlayAmount
			else:
				overlayColorList.append(Layer.new())
				overlayColorList[i-overlayColorListSkipped].alternateList.append(Alternate.new())
				var tempColorList = intermediateColorList[i].alternateList[0].colorList.duplicate()
				overlayColorList[i-overlayColorListSkipped].alternateList[0].colorList = tempColorList
				overlayColorList[i-overlayColorListSkipped].overlayAmount = allColorAmount - intermediateColorList[i].overlayAmount
	
	#Fourth, find any colors on duplicate tiles and mix them together, leaving a single color left
	for i in overlayColorList:
		var startPosition = i.overlayAmount
		var totalAdd = i.alternateList[0].colorList.size()
		for j in totalAdd:
			if startPosition + j < visibleColorList.size():
				var overlayAmount = abs((totalAdd / 2) - j)
				print(overlayAmount)
				var firstMix: Color = visibleColorList[startPosition + j]
				var secondMix: Color = i.alternateList[0].colorList[j]
				var R: float = ((firstMix.r / float(totalAdd)) * float(overlayAmount * 2)) + ((secondMix.r / float(totalAdd)) * (float(totalAdd) - float(overlayAmount * 2)))
				var G: float = ((firstMix.g / float(totalAdd)) * float(overlayAmount * 2)) + ((secondMix.g / float(totalAdd)) * (float(totalAdd) - float(overlayAmount * 2)))
				var B: float = ((firstMix.b / float(totalAdd)) * float(overlayAmount * 2)) + ((secondMix.b / float(totalAdd)) * (float(totalAdd) - float(overlayAmount * 2)))
				visibleColorList[startPosition + j] = Color(R, G, B)
	
	for i in visibleColorList.size(): 
		var instance = colorObject.instantiate()
		if !outline:
			instance.get_child(0).visible = false
		if extras:
			instance.get_child(1).visible = true
		instance.color = visibleColorList[i]
		instance.get_child(1).text = str(i)
		$Control/ColorView/ScrollContainer/HBoxContainer.add_child(instance)

func fadeColor(from:Color, to:Color, fadeAmount:int) -> Array[Color]:
	var colorArray: Array[Color]
	fadeAmount += 1
	var redDifference = (from.r-to.r)/fadeAmount
	var greenDifference = (from.g-to.g)/fadeAmount
	var blueDifference = (from.b-to.b)/fadeAmount
	for i in fadeAmount:
		colorArray.append(Color(from.r-redDifference*i,from.g-greenDifference*i,from.b-blueDifference*i))
	return colorArray

func greatestCommonDivisor(a:int, b:int) -> int:
	if a == 0:
		return b
	else:
		return greatestCommonDivisor(b%a, a)

func lowestCommonMultiplier(a:int, b:int) -> int:
	return (a / greatestCommonDivisor(a, b)) * b;

func lowestCommonMultiplierArray(array:Array[int]) -> int:
	var result:int = array[0]
	for i in array.size():
		result = lowestCommonMultiplier(result, array[i])
	return result

func outputColorset(): 
	var file = FileAccess.open("res://colorset.txt", FileAccess.WRITE)
	var content:String = ""
	var temp = "%X"
	for i in visibleColorList.size():
		if outputType == 0:
			if i == 0:
				content += "#"
				content += "%02X" % (visibleColorList[i].r * 255)
				content += "%02X" % (visibleColorList[i].g * 255)
				content += "%02X" % (visibleColorList[i].b * 255)
			else:
				content += "\n"
				content += "#"
				content += "%02X" % (visibleColorList[i].r * 255)
				content += "%02X" % (visibleColorList[i].g * 255)
				content += "%02X" % (visibleColorList[i].b * 255)
		if outputType == 1:
			if i == 0:
				content += "%02X" % (visibleColorList[i].r * 255)
				content += "%02X" % (visibleColorList[i].g * 255)
				content += "%02X" % (visibleColorList[i].b * 255)
			else:
				content += ","
				content += "%02X" % (visibleColorList[i].r * 255)
				content += "%02X" % (visibleColorList[i].g * 255)
				content += "%02X" % (visibleColorList[i].b * 255)
	file.store_string(content)
