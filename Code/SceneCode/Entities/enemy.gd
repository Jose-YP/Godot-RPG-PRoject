extends "res://Code/SceneCode/Entities/Entity.gd"

@onready var EnemyLabel: RichTextLabel = $NameContainer/RichTextLabel
@onready var enemyData: Enemy = data.specificData
@onready var ScanBox: PanelContainer = $ScanBox
@onready var gettingScanned: bool = false

#SELF VARIABLES
var enemyAI
var aiInstance
var description: String
var moveset: Array = []
#PERCEPTION VARIABLES
var allAllies: Array = []
var allOpposing: Array = []
var allyCurrentTP: int
var allyMaxTP: int
var opposingCurrentTP: int
var opposingMaxTP: int

#-----------------------------------------
#INITALIZATION
#-----------------------------------------
func _ready():
	moreReady()
	EnemyLabel.append_text(str("[b][",data.species,"][/b]",data.name))
	moveset = data.skillData + items
	moveset.append(data.attackData)
	
	enemyAI = load(str(enemyData.AICodePath))
	
	aiInstance = enemyAI.new()
	makeDesc()
	$ScanBox/ScanDescription.append_text(description)

func _process(_delta):
	processer()
	#deletes items after using all of them
	for thing in data.itemData:
		if data.itemData[thing] <= 0:
			moveset.erase(thing)

#-----------------------------------------
#ENEMYAI
#-----------------------------------------
func chooseMove(TP,allies,opposing) -> Move:
	var move: Resource
	allyCurrentTP = TP
	allAllies = allies
	allOpposing = opposing
	var allowed = allowedMoveset(TP)
	
	debugAIPerceive()
	move = aiInstance.basicSelect(allowed)
	if move is Item:
		move = move.attackData
	
	return move

#-----------------------------------------
#ENEMY PERCIEVE SELF
#-----------------------------------------
func selfLeastHealth(limit: float) -> bool: #Returns if low health of self is lower than limit
	var leftover: float = float(currentHP)/data.MaxHP
	return leftover >= limit

func selfElement(desiredElement = ""): #Returns if element is what the user wants
	if desiredElement == "":
		return data.TempElement == desiredElement
	else:
		return true

func selfBuffStatus() -> Array: #Return what conditions is in self
	var buffs = [data.attackBoost, data.defenseBoost, data.speedBoost, data.luckBoost]
	return buffs

func selfCondition() -> Array: #Every condition the self has
	var ConditionArray: Array =[]
	
	for i in range(10):
		#Flag is the binary version of i
		var flag = 1 << i#If it says seekingFlag is a bool, that means it couldn't find a value in String to Flag
		if data.Condition != null and data.Condition & flag != 0:
			ConditionArray.append(HelperFunctions.Flag_to_String(flag,"Condition"))
	
	return ConditionArray

func selfAilments() -> Array: #Return how ailment stack and current Ailment of self
	var ailment = [data.Ailment , data.AilmentNum]
	return ailment

#-----------------------------------------
#ENEMY PERCIEVE GROUP
#-----------------------------------------
func groupLeastHealth(group, limit: float = 1.0): #Returns ally with least health if they're below a threshold
	var leastHealth
	var currentLeftover: float = 1
	var effectiveGroup = getGroup(group)
	
	for entity in effectiveGroup:
		var leftover: float = float(entity.currentHP) / data.MaxHP
		if leftover < currentLeftover:
			leastHealth = entity
			currentLeftover = leftover
	
	if currentLeftover >= limit:
		print(leastHealth, type_string(typeof(leastHealth)))
		return leastHealth 
	else:
		return false

func groupLowHealth(group, limit: float) -> Array: #How many allies are at custom defined low health
	var lowHealthGroup: Array[bool] = []
	var effectiveGroup = getGroup(group)
	
	for entity in effectiveGroup:
		var leftover: float = float(entity.currentHP) / entity.data.MaxHP
		lowHealthGroup.append(leftover >= limit)
	
	return lowHealthGroup

func groupElements(group, desiredElement = "") -> Array: #Return ally elements or if they all meet Desired Element
	var groupElementsArray: Array = []
	var effectiveGroup = getGroup(group)
	
	for entity in effectiveGroup:
		if desiredElement == "":
			groupElementsArray.append(entity.data.TempElement)
		else:
			groupElementsArray.append(entity.data.TempElement == desiredElement)
	
	return groupElementsArray

func groupBuffStatus(group) -> Array: #Return every ally buffs
	var groupBuffs: Array[Array] = []
	var effectiveGroup = getGroup(group)
	
	for entity in effectiveGroup:
		var buffs = [entity.data.attackBoost, entity.data.defenseBoost, entity.data.speedBoost, entity.data.luckBoost]
		groupBuffs.append(buffs)
	
	return groupBuffs

func groupCondition(group) -> Array: #Return what conditions is in every ally
	var groupConditions: Array[Array] = []
	var effectiveGroup = getGroup(group)
	
	for entity in effectiveGroup:
		var conditionArray: Array = []
		for i in range(10):
			#Flag is the binary version of i
			var flag = 1 << i#If it says seekingFlag is a bool, that means it couldn't find a value in String to Flag
			if entity.data.Condition != null and entity.data.Condition & flag:
				conditionArray.append(HelperFunctions.Flag_to_String(flag,"Condition"))
		groupConditions.append(conditionArray)
	
	return groupConditions

func groupAilments(group) -> Array: #Return how ailment stack and current Ailment of allies
	var groupAilmentsArray: Array[Array] = []
	var effectiveGroup = getGroup(group)
	
	for entity in effectiveGroup:
		var ailment = [entity.data.Ailment , entity.data.AilmentNum]
		groupAilmentsArray.append(ailment)
	
	return groupAilmentsArray

func learnOpposing(): #REACTIONARY: Learn any other wierd tricks the players are using
	pass

#-----------------------------------------
#ENEMY PERCIEVE OTHER
#-----------------------------------------
func internalizeAura():
	pass

func internalizeTP(type):
	match type:
		"Current":
			return allyCurrentTP > opposingCurrentTP
		"Max":
			return allyMaxTP > opposingMaxTP
		"Predict":
			return allyCurrentTP + allyMaxTP * .5
		"Hedge":
			return opposingCurrentTP + opposingMaxTP * .5

#-----------------------------------------
#TARGETTING TYPES
#-----------------------------------------
func SingleSelect(targetting,_move):
	var trgt
	match enemyData.AIType:
		"Random":
			trgt = aiInstance.Single(targetting)
			return trgt
		"Pick Off":
			pass
		"Support":
			pass
		"Debuff":
			pass

func GroupSelect(targetting,_move):
	var trgt
	match enemyData.AIType:
		"Random":
			trgt = aiInstance.Single(targetting)
			return trgt
		"Pick Off":
			pass
		"Support":
			pass
		"Debuff":
			pass

#-----------------------------------------
#UI CHANGES
#-----------------------------------------
func displayMove(move) -> void:
	InfoBox.show()
	Info.text = str(data.name, " used ", move.name)

func makeDesc() -> void:
	var foundWeak: bool
	var foundRes: bool
	var weak: String = ""
	var resist: String = ""
	var moveString: String = ""
	var itemString: String = ""
	var stats = str("str:",data.strength,"| tgh:",data.toughness," | bal:",data.ballistics
	,"\nres:",data.resistance," | spd:",data.speed," | luk:",data.luck)
	
	for i in range(10):
		#Flag is the binary version of i
		var flag = 1 << i
		if flag & data.Weakness:
			foundWeak = true
			if flag & 512: #Override all else if All is present
				weak = str(HelperFunctions.colorElements(HelperFunctions.Flag_to_String(flag,"Element")))
			else:
				weak = str(HelperFunctions.colorElements(HelperFunctions.Flag_to_String(flag,"Element")),weak)
		if flag & data.Resist:
			foundRes = true
			if flag & 512:
				resist = str(HelperFunctions.colorElements(HelperFunctions.Flag_to_String(flag,"Element")))
			else:
				resist = str(HelperFunctions.colorElements(HelperFunctions.Flag_to_String(flag,"Element")),", ",resist)
	
	if foundWeak:
		weak = str("Weak: ", weak)
	if foundRes:
		resist = str("Res: ", resist)
	
	for move in moveset:
		if move.name == "Attack" or move.name == "Wait":
			continue
		
		if move is Item:
			if itemString != "":
				itemString = str(items,",","[",data.itemData.get(move),"/",move.maxItems,"]",move.name)
			else:
				itemString = str("[",data.itemData.get(move),"/",move.maxItems,"]",move.name)
			
		else:
			if moveString != "":
				moveString = str(moveString,",",move.name)
			else:
				moveString = str(move.name)
	
	if moveString != "":
		moveString = str("Moves: ", moveString)
	if itemString != "":
		itemString = str("Items:", itemString)
	
	if weak == "":
		weak = str("No Weaknesses")
	if resist == "":
		resist = str("No Resistances")
	if moveString == "":
		moveString = str("Only Attacks")
	if itemString == "":
		itemString = str("No Items")
	
	description = str(weak,"\n",resist,"\n",stats,"\n",moveString,"\n",itemString)

#-----------------------------------------
#PAYING ITEM&TP
#-----------------------------------------
func payCost(move) -> int:
	if move.CostType == "Item":
		for item in data.itemData:
			if item.name == move.name:
				data.itemData[item] -= move.cost
	
	return int(move.TPCost - (data.speed * (1 + data.speedBoost)))

func allowedMoveset(TP) -> Array:
	var allowed: Array = []
	for move in moveset:
		var use = move
		if move is Item:
			use = move.attackData
		
		var TPCost = use.TPCost - (data.speed * (1 + data.speedBoost))
		if Globals.currentAura == "LowTicks":
			TPCost = TPCost / 2
		
		if TP > TPCost:
			allowed.append(use)
	
	if allowed.size() == 0: #if they can't use anything else they have to wait
		allowed.append(data.waitData)
	
	return allowed

func getGroup(group: String) -> Array:
	if group == "Ally":
		return allAllies
	else:
		return allOpposing

#-----------------------------------------
#DEBUG
#-----------------------------------------
func debugAIPerceive() -> void:
	print("-------------------------------------")
	print("SELF PERCEPTION")
	print("-------------------------------------")
	print("LESS THAN HALF HP: ", selfLeastHealth(.5))
	print("IS ELEMENT FIRE: ", selfElement("Fire"))
	print("BUFFS: ", selfBuffStatus())
	print("CONDITIONS: ", selfCondition())
	print("AILMENTS: ", selfAilments())
	
	print("-------------------------------------")
	print("\nALLY PERCEPTION")
	print("-------------------------------------")
	print("ALLIES: ", allAllies)
	print("LEAST HEALTH ", groupLeastHealth("Ally"))
	print("LESS THAN 50% THOUGH? ", groupLeastHealth("Ally", .5))
	print("LESS THAN 90% HP: ", groupLowHealth("Ally", .9))
	print("ELEMENT: ", groupElements("Ally"))
	print("IS ELEMENT FIRE: ", groupElements("Ally", "Fire"))
	print("BUFFS: ", groupBuffStatus("Ally"))
	print("CONDITIONS: ", groupCondition("Ally"))
	print("AILMENTS: ", groupAilments("Ally"))
	
	print("-------------------------------------")
	print("\nOPPOSING PERCEPTION")
	print("-------------------------------------")
	print("OPPOSING", allOpposing)
	print("LEAST HEALTH ", groupLeastHealth("Opposing"))
	print("LESS THAN 50% THOUGH? ", groupLeastHealth("Opposing", .5))
	print("LESS THAN 90% HP: ", groupLowHealth("Opposing", .9))
	print("ELEMENT: ", groupElements("Opposing"))
	print("IS ELEMENT FIRE: ", groupElements("Opposing", "Fire"))
	print("BUFFS: ", groupBuffStatus("Opposing"))
	print("CONDITIONS: ", groupCondition("Opposing"))
	print("AILMENTS: ", groupAilments("Opposing"))
	
	print("-------------------------------------")
	print("\nOTHER PERCEPTION")
	print("-------------------------------------")
	print("TPS: ALLY:", allyCurrentTP, allyMaxTP)
	print("OPPOSING: ", opposingCurrentTP, opposingMaxTP)
