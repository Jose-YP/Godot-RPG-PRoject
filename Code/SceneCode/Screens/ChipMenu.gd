extends Control

@export var InvChipPanel: PackedScene
@export var playerChipPanel: PackedScene
@export var inputButtonThreshold: float = 1.0
@export var scrollAmmount: int = 55
@export var scrollDeadzone: Vector2 = Vector2(280,420) #x is top value, y is bottom value
#Menus
@onready var chipInv: GridContainer = %InvChip
@onready var playerChips: GridContainer = %PlayerChips
@onready var InvMarkers: Array[Marker2D] = []
@onready var PlayMarkers: Array[Marker2D] = []
@onready var Arrow: Sprite2D = $Arrow
@onready var placeholderPos: Marker2D = $Marker2D
@onready var sortingOptions: OptionButton = %Sorts
#Descriptions
@onready var invChipTitle: RichTextLabel = %InvTitle
@onready var invChipDetails: RichTextLabel = %InvDetails
@onready var invChipDisc: RichTextLabel = %InvDesc
@onready var playerChipTitle: RichTextLabel = %PlayTitle
@onready var playerChipDetails: RichTextLabel = %PlayDetials
@onready var playerChipDisc: RichTextLabel = %PlayDesc
#Current Player Info
@onready var playerResource: RichTextLabel = %NameNRsource
@onready var playerElement: TabContainer = %Player1Element
@onready var playerPhyEle: TabContainer = %PlayerPhyElement1
@onready var playerBattleStats: RichTextLabel = %"BattleStats]"
@onready var CPUText: RichTextLabel = %CPUText
@onready var CPUBar: TextureProgressBar = %EnemyTP

signal chipMenu
signal gearMenu
signal itemMenu
signal exitMenu
signal makeNoise(num)

var ChipIcon = preload("res://Icons/MenuIcons/icons-set-2_0000s_0029__Group_.png")
var InvMenu: Array[Array] = [[],[]]
var PlayMenu: Array[Array] = [[],[]]
var currentInv: Array = []
var markerArray: Array = []
var markerIndex: int = 0
var side: int = 0
var num: int = 0
var inputHoldTime: float = 0.0
var playerIndex: int = 0
var tempIndex: int = 0
var CPUusage: int = 0
var movingChip: bool = false
var acrossPlayers: bool = false
var keepFocus
var grabbedChip
var wasChar

#-----------------------------------------
#INITALIZATION
#-----------------------------------------
func _ready():
	emit_signal("chipMenu")
	
	currentInv = Globals.ChipInventory.inventory
	InventoryFunctions.chipHandler(currentInv)
	getChipInventory()
	
	getPlayerStats(playerIndex)
	getPlayerChips(playerIndex)
	
	InvMenu[0][0].focus.grab_focus()

#-----------------------------------------
#PROCESSING
#-----------------------------------------
func _process(delta):
	if movingChip: movement()
	buttons()
	if movingChip:
		if not acrossPlayers or (acrossPlayers and tempIndex == playerIndex):
			keepFocus.grab_focus()
		if Arrow.global_position.y < scrollDeadzone.x:
			scrollUp()
			Arrow.global_position = markerArray[side][markerIndex].global_position
		elif Arrow.global_position.y > scrollDeadzone.y:
			scrollDown()
			Arrow.global_position = markerArray[side][markerIndex].global_position
	
	if Input.get_vector("Left", "Right", "Up", "Down") == Vector2(0.0,0.0):
		inputHoldTime = 0.0
	else:
		inputHoldTime += delta
		if not movingChip:
			if get_viewport().gui_get_focus_owner().global_position.y < scrollDeadzone.x:
				scrollUp()
			elif get_viewport().gui_get_focus_owner().global_position.y > scrollDeadzone.y:
				scrollDown()

func movement() -> void:
	var held: bool = (inputHoldTime == 0.0 or inputHoldTime > inputButtonThreshold)
	
	if Input.is_action_pressed("Left") and held:
		makeNoise.emit(2)
		if markerIndex%2 == 0 and markerIndex != 0:
			side = swap(side)
		else:
			markerIndex -= 1
		if markerIndex < 0:
			if side == 1:
				side = swap(side)
				markerIndex = 1
			else:
				markerIndex = 0
		if markerIndex > (markerArray[side].size() - 1):
			markerIndex = markerArray[side].size() - 1
		
		Arrow.global_position = markerArray[side][markerIndex].global_position
	
	if Input.is_action_pressed("Right") and held:
		markerIndex += 1
		if markerIndex > (markerArray[side].size() - 1):
			markerIndex = markerArray[side].size() - 1
		elif markerIndex%2 == 0 and markerArray[side][markerIndex].name != "Marker2D2":
			side = swap(side)
			markerIndex -= 2
			if markerIndex - 1 == 0:
				markerIndex -= 1
			if markerIndex > (markerArray[side].size() - 1):
				markerIndex = markerArray[side].size() - 1
		
		Arrow.global_position = markerArray[side][markerIndex].global_position
	
	if Input.is_action_pressed("Up") and held:
		makeNoise.emit(2)
		markerIndex -= 2
		if markerIndex < 0:
			markerIndex = 0
		
		Arrow.global_position = markerArray[side][markerIndex].global_position
	
	if Input.is_action_pressed("Down") and held:
		markerIndex += 2
		if markerIndex > (markerArray[side].size() - 1):
			markerIndex = markerArray[side].size() - 1
		
		Arrow.global_position = markerArray[side][markerIndex].global_position

func buttons() -> void:
	if Input.is_action_just_pressed("Accept"):
		makeNoise.emit(0)
		
		if movingChip:
			movingChip = false
			setFocus(true)
			Arrow.hide()
			
			if markerArray[side][markerIndex] == placeholderPos or markerArray[side][markerIndex].get_parent().inChar:
				if wasChar: sortPlayerChip(grabbedChip)
				elif acrossPlayers: sortPlayerChip(grabbedChip)
				else: addChip(grabbedChip)
			
			elif wasChar: removeChip(grabbedChip)
		
		else:
			keepFocus = get_viewport().gui_get_focus_owner()
			movingChip = true
			setFocus(false)
			var adress = getButtonIndex(keepFocus)
			side = adress.x
			markerIndex = adress.y
			wasChar = keepFocus.get_parent().inChar
			
			Arrow.global_position = get_viewport().gui_get_focus_owner().get_parent().inBetween.global_position
			Arrow.show()
		
	if Input.is_action_just_pressed("Cancel"):
		makeNoise.emit(1)
		if movingChip:
			movingChip = false
			setFocus(true)
			Arrow.hide()
		
		else:
			Globals.currentSave.ChipInventory = Globals.ChipInventory
			exitMenu.emit()
	
	if Input.is_action_just_pressed("X"):
		addChip(grabbedChip)
	
	if Input.is_action_just_pressed("Y"):
		makeNoise.emit(1)
		var select = sortingOptions.selected
		select += 1
		if select >= 3:
			select = 0
		sortingOptions.select(select)
		sortingOptions.item_selected.emit(select)
		
	if Input.is_action_just_pressed("L"):
		makeNoise.emit(2)
		if movingChip:
			tempIndex = playerIndex
			acrossPlayers = true
			keepFocus.release_focus()
			if side == 1:
				markerIndex = 0
		
		playerIndex -= 1
		if playerIndex < 0:
			playerIndex = Globals.every_player_entity.size() - 1
		
		getPlayerStats(playerIndex)
		getPlayerChips(playerIndex)
		
		if get_viewport().gui_get_focus_owner() == null and not acrossPlayers and not PlayMenu.size() == 0:
			PlayMenu[0][0].focus.grab_focus()
	
	if Input.is_action_just_pressed("R"):
		makeNoise.emit(2)
		if movingChip:
			tempIndex = playerIndex
			acrossPlayers = true
			if side == 1:
				markerIndex = 0
		
		playerIndex += 1
		if playerIndex > (Globals.every_player_entity.size() - 1):
			playerIndex = 0
		
		getPlayerStats(playerIndex)
		getPlayerChips(playerIndex)
		
		if get_viewport().gui_get_focus_owner() == null and not acrossPlayers and not PlayMenu.size() == 0:
			PlayMenu[0][0].focus.grab_focus()
	
	#[chip,gear,item]
	if not movingChip: #ZR and ZL
		if Input.is_action_just_pressed("ZL"):
			Globals.currentSave.ChipInventory = Globals.ChipInventory
			itemMenu.emit()
		
		if Input.is_action_just_pressed("ZR"):
			Globals.currentSave.ChipInventory = Globals.ChipInventory
			gearMenu.emit()

#-----------------------------------------
#INVENTORY DOCK
#-----------------------------------------
func getChipInventory() -> void:
	for chip in currentInv:
		var chipPanel = InvChipPanel.instantiate()
		chipPanel.ChipData = chip
		chipPanel.maxNum = chip.maxNum
		chipPanel.connect("getDesc",on_inv_focused)
		chipInv.add_child(chipPanel)
		chipPanel.focus.set_focus_mode(2)
		
		InvMenu[side].append(chipPanel)
		InvMarkers.append(chipPanel.inBetween)
		side = swap(side)
	
	side = 0

func update() -> void:
	InvMenu = [[],[]]
	InvMarkers = []
	var prevKeep
	for thing in chipInv.get_children():  #Delete previous inventory display
		if movingChip and thing == keepFocus.get_parent():
			prevKeep = thing.ChipData
		chipInv.remove_child(thing)
		thing.queue_free()
	
	getChipInventory()
	getPlayerStats(playerIndex)
	getPlayerChips(playerIndex)
	
	
	for thing in chipInv.get_children():
		if thing.ChipData == prevKeep: keepFocus = thing.focus
	
	acrossPlayers = false
	if movingChip: keepFocus.grab_focus()
	else: InvMenu[0][0].focus.grab_focus()

#-----------------------------------------
#PLAYER DOCK
#-----------------------------------------
func getPlayerStats(index) -> void:
	var entity = Globals.getStats(Globals.every_player_entity[index], Globals.every_player_entity[index].name ,Globals.every_player_entity[index].level)
	var CPUtween = CPUBar.create_tween()
	var resourceString = str(Globals.charColor(entity)," [color=red]HP: ",entity.MaxHP,"[/color]"
	,"\n [color=aqua]LP:",entity.specificData.MaxLP," [/color][color=green] TP: ",
	entity.MaxTP,"[/color]")
	var stats = str("STR: ",entity.strength,"\tTGH: ",entity.toughness,"\tSPD: ",entity.speed,
	"\nBAL: ",entity.ballistics,"\tRES: ",entity.resistance,"\tLUK: ",entity.luck)
	var currentCPUtext = str((entity.specificData.MaxCPU - entity.specificData.currentCPU),"/",entity.specificData.MaxCPU,"\nCPU")
	
	playerResource.clear()
	playerBattleStats.clear()
	CPUText.clear()
	
	playerResource.append_text(resourceString)
	playerBattleStats.append_text(stats)
	CPUText.append_text(currentCPUtext)
	
	getElements(entity)
	
	var newValue = int(100*(float(entity.specificData.MaxCPU - entity.specificData.currentCPU) / float(entity.specificData.MaxCPU)))
	CPUtween.tween_property(CPUBar, "value", newValue,.2).set_trans(Tween.TRANS_CIRC).from(entity.specificData.MaxCPU)
	InventoryFunctions.miniChipHandler(entity.name,entity.specificData.ChipData, currentInv)

func getPlayerChips(index) -> void:
	clearPlayerChips()
	
	var entity = Globals.every_player_entity[index]
	entity.specificData.currentCPU = 0
	
	for chip in entity.specificData.ChipData:
		var chipPannel = playerChipPanel.instantiate()
		entity.specificData.currentCPU += chip.CpuCost
		chipPannel.ChipData = chip
		chipPannel.maxNum = chip.maxNum
		chipPannel.connect("getDesc",on_play_focused)
		playerChips.add_child(chipPannel)
		
		PlayMenu[side].append(chipPannel)
		PlayMarkers.append(chipPannel.inBetween)
		
		side = swap(side)
	
	if PlayMenu[0].size() == 0:
		PlayMarkers.append(placeholderPos)
	else:
		PlayMarkers.append(PlayMenu[swap(side)][PlayMenu[side].size() - 1].final)
	side = 0
	markerArray = [InvMarkers,PlayMarkers]

func clearPlayerChips() -> void:
	PlayMenu = [[],[]]
	PlayMarkers = []
	for thing in playerChips.get_children():
		playerChips.remove_child(thing)
		thing.queue_free()

func getElements(entity) -> void:
	for k in range(4):
		if Globals.elementGroups[k] == entity.element:
			playerElement.current_tab = k
	for k in range(3):
		if Globals.XSoftTypes[k+3] == entity.phyElement:
			playerPhyEle.current_tab = k

func addChip(chip) -> void:
	var entity = Globals.every_player_entity[playerIndex]
	if acrossPlayers:
		entity = Globals.every_player_entity[tempIndex]
	
	if (chip.CpuCost <= (entity.specificData.MaxCPU - entity.specificData.currentCPU)
	and not playerHitLimit(entity, chip)):
		entity.specificData.ChipData.insert(markerIndex, chip)
		InventoryFunctions.chipHandlerResult(chip,entity.name,true)
	
	update()

func removeChip(chip) -> void:
	var entity = Globals.every_player_entity[playerIndex]
	if acrossPlayers:
		entity = Globals.every_player_entity[tempIndex]
	
	entity.specificData.ChipData.erase(chip)
	InventoryFunctions.chipHandlerResult(chip,entity.name,false)
	update()

func sortPlayerChip(chip) -> void:
	var entity = Globals.every_player_entity[playerIndex]
	
	if acrossPlayers and chip.CpuCost < (entity.specificData.MaxCPU - entity.specificData.currentCPU):
		var fromEntity = Globals.every_player_entity[tempIndex]
		fromEntity.specificData.ChipData.erase(chip)
		entity.specificData.ChipData.insert(markerIndex, chip)
		InventoryFunctions.chipHandler(currentInv) #Update chip ownership from prev entity
	else:
		entity.specificData.ChipData.erase(chip)
		entity.specificData.ChipData.insert(markerIndex, chip)
	
	update()

#-----------------------------------------
#SIGNALS
#-----------------------------------------
func on_inv_focused(data) -> void:
	makeNoise.emit(2)
	grabbedChip = data.ChipData
	
	invChipTitle.clear()
	invChipTitle.append_text(str(data.ChipData.name, " Chip"))
	
	invChipDetails.clear()
	invChipDetails.append_text(str("[center]",data.ChipData.ChipType," Chip\nOwners:",
	data.currentPlayers,"[/center]"))
	
	invChipDisc.clear()
	invChipDisc.append_text(data.ChipData.description)

func on_play_focused(data) -> void:
	makeNoise.emit(2)
	grabbedChip = data.ChipData
	
	playerChipTitle.clear()
	playerChipTitle.append_text(str(data.ChipData.name, " Chip"))
	
	playerChipDetails.clear()
	playerChipDetails.append_text(str("[center]",data.ChipData.ChipType," Chip[/center]"))
	
	playerChipDisc.clear()
	playerChipDisc.append_text(data.ChipData.description)

func _on_option_button_item_selected(index) -> void:
	makeNoise.emit(0)
	var newSort = sortingOptions.get_item_text(index)
	match newSort:
		"Sort Alpha": currentInv = Globals.ChipInventory.inventory
		"Sort Color": currentInv = Globals.ChipInventory.inventorySort1
		"Sort Cost": currentInv = Globals.ChipInventory.inventorySort2
	
	update()

#-----------------------------------------
#HELPER FUNCTIONS
#-----------------------------------------
func swap(value) -> int:
	if value == 0:
		value += 1
	else:
		value -= 1
	return value

func scrollUp() -> void:
	if acrossPlayers:
		if side == 0:
			chipInv.get_parent().scroll_vertical -= scrollAmmount
		else:
			playerChips.get_parent().scroll_vertical -= scrollAmmount
	else:
		if get_viewport().gui_get_focus_owner().get_parent().inChar:
			playerChips.get_parent().scroll_vertical -= scrollAmmount
		else:
			chipInv.get_parent().scroll_vertical -= scrollAmmount

func scrollDown() -> void:
	if acrossPlayers:
		if side == 0:
			chipInv.get_parent().scroll_vertical += scrollAmmount
		else:
			playerChips.get_parent().scroll_vertical += scrollAmmount
	else:
		if get_viewport().gui_get_focus_owner().get_parent().inChar:
			playerChips.get_parent().scroll_vertical += scrollAmmount
		else:
			chipInv.get_parent().scroll_vertical += scrollAmmount

func setFocus(value: bool) -> void:
	if side == 0:
		chipInv.get_parent().set_follow_focus(value)
	else:
		playerChips.get_parent().set_follow_focus(value)

func getButtonIndex(searching) -> Vector2:
	var menu: Array
	var found: int
	var locSide: int
	var dock: int
	
	searching = searching.get_parent()
	if searching.inChar:
		menu = InvMenu
		dock = 0
	else:
		menu = PlayMenu
		dock = 1
	
	for adress in range(menu.size()):
		for button in range(menu[adress].size()):
			if menu[adress][button] == searching:
				found = button * 2
				locSide = adress
				break
	
	if locSide == 1:
		found += 1
	
	return Vector2(dock, found)

func playerHitLimit(player, chip) -> bool:
	var times: int = 0
	for playerChip in player.specificData.ChipData:
		if playerChip.name == chip.name:
			times += 1
	
	if times >= 2:
		return true
	else:
		return false
