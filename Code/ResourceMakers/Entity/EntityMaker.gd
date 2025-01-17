extends Resource
class_name entityData

@export_category("Information")
@export_range(1,60) var level: int
@export var name: String
@export var species: String
@export_enum("Stellar","Hybrid","Non-Stellar") var stellar: String = "Stellar"
@export var specificData: Resource

@export_group("Stats")
@export_subgroup("Resource Stats")
@export var MaxHP: int = 1
@export_range(80,300) var MaxTP: int = 80
@export_subgroup("Battle Stats")
@export_range(0,60) var strength: int
@export_range(0,60) var toughness: int
@export_range(0,60) var ballistics: int
@export_range(0,60) var resistance: int
@export_range(0,60) var speed: int
@export_range(0,60) var luck: int

@export_group("Element Properties")
@export_subgroup("Element")
@export_enum("Fire","Water","Elec","Neutral") var element: String = "Fire"
@export_enum("Slash","Crush","Pierce","Neutral") var phyElement: String = "Neutral"
@export_range(-1,1,.05) var soloElementMod: float = 0.0
@export_range(-1,1,.05) var groupElementMod: float = 0.0
@export_range(-1,1,.05) var phyElementMod: float = 0.0
@export var sameElement: bool = false
@export_subgroup("Reactions")
@export_flags("Fire","Water","Elec","Slash","Crush","Pierce","Comet","Light","Aurora","All") var Weakness: int = 0
@export_flags("Fire","Water","Elec","Slash","Crush","Pierce","Comet","Light","Aurora","All") var strong: int = 0
@export_enum("Overdrive","Poison","Reckless","Exhausted","Rust","Stun","Curse","None","Protected",
"Dumbfounded","Miserable","Worn Out", "Explosive","XSoft","Mental","Chemical","Debuff") 
var immunity: String = "None"

@export_group("Attack Properties")
@export_subgroup("Attacks")
@export var attackData: Move
@export var skillData: Array[Move] = []
@export var itemData: Dictionary = {}
@export var waitData: Move
@export_subgroup("Calc Bonuses")
@export_flags("Physical","Ballistic","Freebie") var ItemChange: int = 0
@export_flags("HP","LP","TP") var costBonus: int = 0
@export_range(0,2,.05) var HpCostMod: float = 0.0
@export_range(0,2,.05) var LpCostMod: float = 0.0
@export_range(0,2,.05) var TpCostMod: float = 0.0
@export_flags("Drain","AilmentHit","CritChance") var calcBonus: int = 0
@export_range(0,1,.05) var drainCalcAmmount: float = 0.0
@export_range(0,1,.05) var ailmentCalcAmmount: float = 0.0
@export_range(0,1,.05) var critCalcAmmount: float = 0.0

@export_group("Temp Property")
@export_subgroup("Misc")
@export var KO: bool = false
@export var XSoft: Array[String] = ["","",""]
@export_flags("Charge","Amp","Targetted","Endure","Peace","Lucky","Reflect","Absorb","Devoid","AnotherTurn") var Condition: int = 0
@export_enum("Fire","Water","Elec","Neutral") var TempElement: String = element
@export_enum("None","Explode","LPDrain","DumbfoundedCrit") var miscCalc: String = "None"
@export_subgroup("Ailments")
@export_enum("Overdrive","Poison","Reckless","Exhausted","Rust","Stun","Curse",
"Protected","Dumbfounded","Miserable","Worn Out", "Explosive","Healthy") var Ailment: String = "Healthy"
@export_range(0,3) var AilmentNum: int = 0
@export_subgroup("Stat Boosts")
@export_range(-.6,.6,.05) var attackBoost: float = 0
@export_range(-.6,.6,.05) var defenseBoost: float = 0
@export_range(-.6,.6,.05) var speedBoost: float = 0
@export_range(-.6,.6,.05) var luckBoost: float = 0
