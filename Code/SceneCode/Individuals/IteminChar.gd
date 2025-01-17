extends PanelContainer

@onready var focus: Button = $Button
@onready var inBetween: Marker2D = $Marker2D
@onready var final: Marker2D = $Marker2D2
@onready var icon: TextureRect = $Button/MarginContainer/Item/TextureRect
@onready var itemText: RichTextLabel = $Button/MarginContainer/Item/MarginContainer/RichTextLabel
@onready var autofillStatus: TabContainer = $Button/MarginContainer/Item/AutofillStatus

signal getDesc(data)
signal startSelect(data)

var itemData: Item
var maxNum: int
var currentNum: int
var inChar: bool = true
var autofillOn: bool = false

func _ready():
	icon.texture = itemData.icon
	if autofillOn: autofillStatus.current_tab = 1
	
	itemText.clear()
	itemText.append_text(str("[center]",itemData.name,"[/center][right][color=gray]",currentNum,"/",maxNum,"[/color]"))

func _on_button_focus_entered() -> void:
	getDesc.emit(self)
