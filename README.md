Heyo, this is a prototypeRPG I'm making to learn Godot

Here's how things are supposed to functions
I'm going to keep updating this until the GameJam starts so maybe it'll look better tommorow

______
STATS
_____
HP:    Health Points, when 0 you die
LP:    Mana, they're only called LP because I played Okage: Shadow King lol
strength:  Physical Attack
toughness:  Physical Defense
ballistics:  Ballistic Attack (aka magic)
resistance:  Ballistic Defense
speed:  Lowers TP cost of moves (likely not implemented yet)
luck:  Raises chance of getting crit/ailment hits and lowers opponents chances of doing the same to you

_______
PROPERTIES
_______
Elements: There are four regular elements: Fire, Water, Elec and Neutral. 
Fire, Water and Elec have a RPS system against eachother  Fire beats Elec,  Elec beats Water, Water beats Fire
the winning element takes less damage, deals more damage and has a higher chance to inflict Ailments.
If a move has a non-Neutral element tied to it, the defender will have to take that element's damage
Otherwise offensive element depends on user's element (Neutral using neutral will be just neutral)

PhyElements: Some moves have PhyElements Alash/Crush/Pierce. If an entity has a Weakness, it'll deal more damage,
and Resistance will deal less damage. However Weaknesses take priority even if they have a Resistance at the same time

There are several other offensive elements but they likely won't be used

Weakness/Resist: Entities can also have Elemental Weak/Resists on top of their normal element

_______
BUFFS
_______
Four stats can be buffed twice, each stack gives a 30% boost to:
Attack, Defense, Speed or Luck
They don't directly buff stats but they will be there to help any calc with those stats

______
AILMENTS
______
Ailments, aka Status Consitions
Most can be stacked 3 times for worsening effects with the only exception being Overdrive
You can only have one Ailment stacked
They probably won't be implemented by the time the GameJam starts but here's a few examples
Poison
1-
2-
3-
Reckless
1-
2-
3-
Protected
1-
2-
3-

XSofts are a seperate kind of Status Effect
The first Soft of a certain element will make the entity take 15% more damage to that element
proceeeding Softs of the same element will add 10%
The six softs are Fire,Water,Elec,Slash,Crush & Pierce 
They will be applied whener you crit, with PhyElements taking priority
You can only have a total of 3 softs of any type

______
CONDITIONS
______
Status Ailments that can't be stacked on their own

ex. You can only charge once but you can have charge with another condition
______
______
_______
MOVES
_______

Move Properties)
Physical: Deal Physical Damage tend to cost HP for players
Ballistic: Deal Ballistic Damage tend to cost LP for players
Bomb: Deal Damage without the user's attack or enemy's defense stat tend to be items
Buff: Chance a property of the target[Stat Buff, Condition or Element] tend to cost LP for players
Heal: Heal HP and/or remove Ailments tend to cost LP for players
Aura: Add a feild condition tend to be items
Summon: Add an entity to the field (likely won't be implemented) Enemy Exclusive
Ailment: Inflict a certain Ailment/XSoft, if chance is 200% it's guaranteed tends to be paired with another property
Misc: If needed use a custom function

Move Targets)
Single: Attack a single entity X times
Group: Attack a group of entities of the same element X times. If there is only one entity, attack them 2X times
Random: For X times, attack a random enemy
Self: You
All: Attack every entity X times

______
TP MANAGEMENT
______
Unlikely to be implemented once the game jam starts but

