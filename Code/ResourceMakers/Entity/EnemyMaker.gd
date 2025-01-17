extends Resource
class_name Enemy

@export_category("Drops")
@export var xp: int
@export var cents: int

@export_category("Properties")
@export var Boss: bool
@export var Revivable: bool

@export_group("AI")
@export var AICodePath: String = ""
@export var hasMisc: bool = false
@export var Priorities: Array[String] = ["Misc","Summon","Aura","Condition",
"Buff","Debuff","Element","Ailment","Heal","Attack"] #Reordered depending on user
@export var PriorityChance: Array[int] = [10,50,50,50,
50,50,50,50,50,100] #When multiple conditions are met use chances that are before 100

@export_subgroup("Resource Preferences")
@export_range(0,1,.05) var selfHPPreference: float = 0
@export_range(0,1,.05) var allyHPPreference: float = 0
@export_range(0,1,.05) var oppHPPreference: float = 0

@export_subgroup("Ailment Preferences")
@export_range(0,3) var selfAilmentPreference: int = 1
@export_range(0,3) var allyAilmentPreference: int = 2
@export_range(0,9) var allyTotalAilmentPreference: int = 7
@export_range(0,3) var oppAilmentPreference: int = 1
@export_range(0,9) var oppTotalAilmentPreference: int = 4
@export_flags("Overdrive","Poison","Reckless","Exhausted","Rust","Stun","Curse","Protected",
"Dumbfounded","Miserable","Worn Out", "Explosive","XSoft") var favoredAilments: int = 3966 #126+256+512+1024+2048
@export_range(0,3) var selfXSoftPreference: int = 2
@export_range(0,3) var allyXSoftPreference: int = 1
@export_range(0,3) var oppXSoftPreference: int = 2
@export_flags("Fire","Water","Elec","Slash","Crush","Pierce") var favoredXSoftTypes: int

@export_subgroup("Stat Buff Preferences")
@export_flags("Attack","Defense","Speed","Luck") var allyBoostTypePreference: int = 15
@export_range(0,4) var selfBuffNumPreference: int = 1
@export_range(-.6,.6,.05) var selfBuffAmmountPreference: float = .1
@export_range(0,4) var allyBuffNumPreference: int = 1
@export_range(-.6,.6,.05) var allyBuffAmmountPreference: float = .1
@export_flags("Attack","Defense","Speed","Luck") var oppBoostTypePreference: int = 15
@export_range(0,4) var oppBuffNumPreference: int = 1
@export_range(-.6,.6,.05) var oppBuffAmmountPreference: float = .1

@export_subgroup("Other Buff Preferences")
@export_flags("Charge","Amp","Targetted","Endure","Peace","Lucky",
"Reflect","Absorb","Devoid","AnotherTurn") var favoredCondition: int = 763
@export var allyElementPreference: int = 2
@export var oppElementPreference: int = 2
@export_enum("Fire","Water","Elec","Neutral","Null") var selfFavoredElement = "Null"
@export_enum("Fire","Water","Elec","Neutral","Null") var allyFavoredElement = "Null"
@export_enum("Fire","Water","Elec","Neutral","Null") var oppFavoredElement = "Null"
@export_enum("Fire","Water","Elec","Neutral","Null") var selfUnfavoredElement = "Null"
@export_enum("Fire","Water","Elec","Neutral","Null") var allyUnfavoredElement = "Null"
@export_enum("Fire","Water","Elec","Neutral","Null") var oppUnfavoredElement = "Null"

@export_subgroup("Favor Preferences")
@export var favorBoss: bool = false
@export_flags("BodyBroken","WillWrecked","DoubleCrits","LowTP") var favoredAuras: int = 15
@export var favoredAlly: String = ""
@export_enum("DREAMER","Lonna","Damir","Pepper", "None") var hatedOpponent: String = "None"
