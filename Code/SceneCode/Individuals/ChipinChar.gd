extends PanelContainer

@onready var focus: Button = $Button
@onready var inBetween: Marker2D = $Marker2D
@onready var final: Marker2D = $Marker2D2
@onready var iconColor: TextureRect = $Button/MarginContainer/Chip1/TextureRect
@onready var chipText: RichTextLabel = $Button/MarginContainer/Chip1/MarginContainer/RichTextLabel

signal getDesc(data)
signal startSelect(data)

var ChipData: Chip
var maxNum: int
var currentNum: int
var inChar: bool = true

func _ready():
	match ChipData.ChipType:
		"Red":
			iconColor.modulate = Color.RED
		"Blue":
			iconColor.modulate = Color.BLUE
		"Yellow":
			iconColor.modulate = Color.YELLOW
	
	chipText.clear()
	var cost = ChipData.CpuCost
	if cost < 0:
		cost = str("+", ChipData.CpuCost * -1)
	
	chipText.append_text(str(ChipData.name," Chip | [color=yellow]CPU: ",cost,"[/color]"))

func _on_button_focus_entered() -> void:
	getDesc.emit(self)
