extends Control

@export var InvItemPanel: PackedScene
@export var playerItemPanel: PackedScene
@export var scrollAmmount: int = 55
@export var scrollDeadzone: Vector2 = Vector2(280,420) #x is top value, y is bottom value
#Menus
@onready var itemInv: GridContainer = $VBoxContainer/HBoxContainer/ItemSelection/VBoxContainer/ItemSelection/GridContainer
@onready var playerItems: GridContainer = $VBoxContainer/HBoxContainer/CurrentCharItems/VBoxContainer/CurrentItems/PanelContainer
@onready var InvMarkers: Array[Marker2D] = []
@onready var PlayMarkers: Array[Marker2D] = []
@onready var Arrow: Sprite2D = $Arrow
@onready var placeholderPos: Marker2D = $Marker2D
@onready var sortingOptions: OptionButton = $VBoxContainer/HBoxContainer/ItemSelection/VBoxContainer/INVENTORYTEXT/HBoxContainer/MarginContainer/Panel/OptionButton
#Descriptions
@onready var invItemTitle: RichTextLabel = $VBoxContainer/HBoxContainer/ItemSelection/VBoxContainer/Info/QuickInfo/HBoxContainer/Title/RichTextLabel
@onready var invItemDetails: RichTextLabel = $VBoxContainer/HBoxContainer/ItemSelection/VBoxContainer/Info/QuickInfo/HBoxContainer/Details/RichTextLabel
@onready var invItemDisc: RichTextLabel = $VBoxContainer/HBoxContainer/ItemSelection/VBoxContainer/Info/Description/RichTextLabel
@onready var playerItemTitle: RichTextLabel = $VBoxContainer/HBoxContainer/CurrentCharItems/VBoxContainer/Info/QuickInfo/HBoxContainer/Title/RichTextLabel
@onready var playerItemDetails: RichTextLabel = $VBoxContainer/HBoxContainer/CurrentCharItems/VBoxContainer/Info/QuickInfo/HBoxContainer/Details/RichTextLabel
@onready var playerItemDisc: RichTextLabel = $VBoxContainer/HBoxContainer/CurrentCharItems/VBoxContainer/Info/MarginContainer/Description/RichTextLabel
#Current Player Info
@onready var playerResource: RichTextLabel = $VBoxContainer/HBoxContainer/CurrentCharItems/VBoxContainer/CharacterInfo/Character/RichTextLabel
@onready var playerElement: TabContainer = $VBoxContainer/HBoxContainer/CurrentCharItems/VBoxContainer/CharacterInfo/Player1Element
@onready var playerPhyEle: TabContainer = $VBoxContainer/HBoxContainer/CurrentCharItems/VBoxContainer/CharacterInfo/PlayerPhyElement1
@onready var playerBattleStats: RichTextLabel = $VBoxContainer/HBoxContainer/CurrentCharItems/VBoxContainer/CharacterInfo/Stats/RichTextLabel
@onready var CPUText: RichTextLabel = $VBoxContainer/HBoxContainer/CurrentCharItems/VBoxContainer/CharacterInfo/CPUBox/HBoxContainer/RichTextLabel
@onready var CPUBar: TextureProgressBar = $VBoxContainer/HBoxContainer/CurrentCharItems/VBoxContainer/CharacterInfo/CPUBox/HBoxContainer/EnemyTP

signal gearMenu
signal chipMenu
signal exitMenu
signal makeNoise(num)

var InvMenu: Array[Array] = [[],[]]
var PlayMenu: Array[Array] = [[],[]]
var currentInv: Array = []
var markerArray: Array = []
var markerIndex: int = 0
var side: int = 0
var num: int = 0
var playerIndex: int = 0
var tempIndex: int = 0
var CPUusage: int = 0
var movingItem: bool = false
var acrossPlayers: bool = false
var keepFocus
var grabbedItem
var wasChar

#-----------------------------------------
#INITALIZATION
#-----------------------------------------
func _ready():
	emit_signal("itemMenu")
	
	currentInv = Globals.ItemInventory.inventory
	InventoryFunctions.itemHandler(currentInv)
	getItemInventory()
	
	getPlayerStats(playerIndex)
	getPlayerItems(playerIndex)
	
	InvMenu[0][0].focus.grab_focus()

#-----------------------------------------
#PROCESSING
#-----------------------------------------
func _process(_delta):
	if movingItem:
		movement()
	buttons()
	if movingItem:
		if not acrossPlayers or (acrossPlayers and tempIndex == playerIndex):
			keepFocus.grab_focus()
		if Arrow.global_position.y < scrollDeadzone.x:
			scrollUp()
			Arrow.global_position = markerArray[side][markerIndex].global_position
		elif Arrow.global_position.y > scrollDeadzone.y:
			scrollDown()
			Arrow.global_position = markerArray[side][markerIndex].global_position

func movement() -> void:
	if Input.is_action_just_pressed("Left"):
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
	
	if Input.is_action_just_pressed("Right"):
		markerIndex += 1
		if markerIndex%2 == 0:
			side = swap(side)
			markerIndex -= 1
		if markerIndex > (markerArray[side].size() - 1):
			markerIndex = markerArray[side].size() - 1
		
		Arrow.global_position = markerArray[side][markerIndex].global_position
	
	if Input.is_action_just_pressed("Up"):
		markerIndex -= 2
		if markerIndex < 0:
			markerIndex = 0
		
		Arrow.global_position = markerArray[side][markerIndex].global_position
	
	if Input.is_action_just_pressed("Down"):
		markerIndex += 2
		if markerIndex > (markerArray[side].size() - 1):
			markerIndex = markerArray[side].size() - 1
		
		Arrow.global_position = markerArray[side][markerIndex].global_position

func buttons() -> void:
	if Input.is_action_just_pressed("Accept"):
		makeNoise.emit(0)
		
		if movingItem:
			if markerArray[side][markerIndex] == placeholderPos or markerArray[side][markerIndex].get_parent().inChar:
				if wasChar:
					sortPlayerItem(grabbedItem)
				else:
					if acrossPlayers:
						sortPlayerItem(grabbedItem)
					else:
						addItem(grabbedItem)
			else:
				if wasChar:
					removeItem(grabbedItem)
			
			
			movingItem = false
			Arrow.hide()
		
		else:
			keepFocus = get_viewport().gui_get_focus_owner()
			if keepFocus is OptionButton:
				sortingOptions.press()
			else:
				movingItem = true
				var adress = getButtonIndex(keepFocus)
				side = adress.x
				markerIndex = adress.y
				wasChar = keepFocus.get_parent().inChar
				
				Arrow.global_position = get_viewport().gui_get_focus_owner().get_parent().inBetween.global_position
				Arrow.show()
		
	if Input.is_action_just_pressed("Cancel"):
		makeNoise.emit(1)
		if movingItem:
			movingItem = false
			Arrow.hide()
		else:
			exitMenu.emit()
	
	if Input.is_action_just_pressed("X"):
		exitMenu.emit()
	
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
		if movingItem:
			tempIndex = playerIndex
			acrossPlayers = true
			keepFocus.release_focus()
			if side == 1:
				markerIndex = 0
		
		playerIndex -= 1
		if playerIndex < 0:
			playerIndex = Globals.every_player_entity.size() - 1
		
		getPlayerStats(playerIndex)
		getPlayerItems(playerIndex)
		
		if get_viewport().gui_get_focus_owner() == null and not acrossPlayers:
			PlayMenu[0][0].focus.grab_focus()
	
	if Input.is_action_just_pressed("R"):
		makeNoise.emit(2)
		if movingItem:
			tempIndex = playerIndex
			acrossPlayers = true
			if side == 1:
				markerIndex = 0
		
		playerIndex += 1
		if playerIndex > (Globals.every_player_entity.size() - 1):
			playerIndex = 0
		
		getPlayerStats(playerIndex)
		getPlayerItems(playerIndex)
		
		if get_viewport().gui_get_focus_owner() == null and not acrossPlayers:
			PlayMenu[0][0].focus.grab_focus()
	
	#[item,gear,item]
	if not movingItem: #ZR and ZL
		if Input.is_action_just_pressed("ZL"):
			itemMenu.emit()
		
		if Input.is_action_just_pressed("ZR"):
			gearMenu.emit()

#-----------------------------------------
#INVENTORY DOCK
#-----------------------------------------
func getItemInventory() -> void:
	for item in currentInv:
		var itemPanel = InvItemPanel.instantiate()
		itemPanel.ItemData = item
		itemPanel.maxNum = item.maxNum
		itemPanel.connect("getDesc",on_inv_focused)
		itemInv.add_child(itemPanel)
		itemPanel.focus.set_focus_mode(2)
		
		InvMenu[side].append(itemPanel)
		InvMarkers.append(itemPanel.inBetween)
		side = swap(side)
	
	InvMarkers.append(InvMenu[side][-1].final)
	side = 0

func update() -> void:
	InvMenu = [[],[]]
	InvMarkers = []
	var prevKeep
	for thing in itemInv.get_children():
		if movingItem and thing == keepFocus.get_parent():
			prevKeep = thing.ItemData
		itemInv.remove_child(thing)
		thing.queue_free()
	
	getPlayerStats(playerIndex)
	getItemInventory()
	getPlayerItems(playerIndex)
	
	for thing in itemInv.get_children():
		if thing.ItemData == prevKeep:
			keepFocus = thing.focus
	
	acrossPlayers = false
	if movingItem:
		keepFocus.grab_focus()
	else:
		InvMenu[0][0].focus.grab_focus()

#-----------------------------------------
#PLAYER DOCK
#-----------------------------------------
func getPlayerStats(index) -> void:
	var entity = Globals.getStats(Globals.every_player_entity[index], Globals.every_player_entity[index].name ,Globals.every_player_entity[index].level)
	var CPUtween = CPUBar.create_tween()
	var resourceString = str(Globals.charColor(entity)," [color=red]HP: ",entity.MaxHP,"[/color]"
	,"\n [color=aqua]LP:",entity.specificData.MaxLP," [/color][color=green]",
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
	InventoryFunctions.miniItemHandler(entity.name,entity.specificData.ItemData, currentInv)

func getPlayerItems(index) -> void:
	clearPlayerItems()
	
	var entity = Globals.every_player_entity[index]
	entity.specificData.currentCPU = 0
	
	for item in entity.specificData.ItemData:
		var itemPannel = playerItemPanel.instantiate()
		entity.specificData.currentCPU += item.CpuCost
		itemPannel.ItemData = item
		itemPannel.maxNum = item.maxNum
		itemPannel.connect("getDesc",on_play_focused)
		playerItems.add_child(itemPannel)
		
		PlayMenu[side].append(itemPannel)
		PlayMarkers.append(itemPannel.inBetween)
		
		side = swap(side)
	
	if PlayMenu[0].size() == 0:
		PlayMarkers.append(placeholderPos)
	else:
		PlayMarkers.append(PlayMenu[swap(side)][PlayMenu[side].size() - 1].final)
	side = 0
	markerArray = [InvMarkers,PlayMarkers]

func clearPlayerItems() -> void:
	PlayMenu = [[],[]]
	PlayMarkers = []
	for thing in playerItems.get_children():
		playerItems.remove_child(thing)
		thing.queue_free()

func getElements(entity) -> void:
	for k in range(4):
		if Globals.elementGroups[k] == entity.element:
			playerElement.current_tab = k
	for k in range(3):
		if Globals.XSoftTypes[k+3] == entity.phyElement:
			playerPhyEle.current_tab = k

func addItem(item) -> void:
	var entity = Globals.every_player_entity[playerIndex]
	if acrossPlayers:
		entity = Globals.every_player_entity[tempIndex]
	
	if item.CpuCost < (entity.specificData.MaxCPU - entity.specificData.currentCPU):
		entity.specificData.ItemData.insert(markerIndex, item)
		update()

func removeItem(item) -> void:
	var entity = Globals.every_player_entity[playerIndex]
	if acrossPlayers:
		entity = Globals.every_player_entity[tempIndex]
	
	entity.specificData.ItemData.erase(item)
	update()

func sortPlayerItem(item) -> void:
	var entity = Globals.every_player_entity[playerIndex]
	
	if acrossPlayers and item.CpuCost < (entity.specificData.MaxCPU - entity.specificData.currentCPU):
		var fromEntity = Globals.every_player_entity[tempIndex]
		fromEntity.specificData.ItemData.erase(item)
		entity.specificData.ItemData.insert(markerIndex, item)
		InventoryFunctions.itemHandler(currentInv) #Update item ownership from prev entity
	else:
		entity.specificData.ItemData.erase(item)
		entity.specificData.ItemData.insert(markerIndex, item)
	
	update()

#-----------------------------------------
#SIGNALS
#-----------------------------------------
func on_inv_focused(data) -> void:
	makeNoise.emit(2)
	grabbedItem = data.ItemData
	
	invItemTitle.clear()
	invItemTitle.append_text(str(data.ItemData.name, " Item"))
	
	invItemDetails.clear()
	invItemDetails.append_text(str("[center]",data.ItemData.ItemType," Item\nOwners:",
	data.currentPlayers,"[/center]"))
	
	invItemDisc.clear()
	invItemDisc.append_text(data.ItemData.description)

func on_play_focused(data) -> void:
	makeNoise.emit(2)
	grabbedItem = data.ItemData
	
	playerItemTitle.clear()
	playerItemTitle.append_text(str(data.ItemData.name, " Item"))
	
	playerItemDetails.clear()
	playerItemDetails.append_text(str("[center]",data.ItemData.ItemType," Item[/center]"))
	
	playerItemDisc.clear()
	playerItemDisc.append_text(data.ItemData.description)

func _on_option_button_item_selected(index) -> void:
	makeNoise.emit(0)
	var newSort = sortingOptions.get_item_text(index)
	match newSort:
		"Sort Alpha":
			currentInv = Globals.ItemInventory.inventory
		"Sort Color":
			currentInv = Globals.ItemInventory.inventorySort1
		"Sort Cost":
			currentInv = Globals.ItemInventory.inventorySort2
	
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
	if side == 0:
		itemInv.get_parent().scroll_vertical -= scrollAmmount
	else:
		playerItems.get_parent().scroll_vertical -= scrollAmmount

func scrollDown() -> void:
	if side == 0:
		itemInv.get_parent().scroll_vertical += scrollAmmount
	else:
		playerItems.get_parent().scroll_vertical += scrollAmmount

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
