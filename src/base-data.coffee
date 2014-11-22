Item = require './item'

data = require '../data/pokemon.json'

statNames = ['hp', 'atk', 'def', 'spd', 'spAtk', 'spDef']

exports.baseDataSize = baseDataSize = 28

exports.types = types = [
	'normal', 'fighting', 'flying', 'poison'
	'ground', 'rock', 'bug', 'ghost', 'steel'
	'???', 'fire', 'water', 'grass', 'electric'
	'psychic', 'ice', 'dragon', 'dark'
]

exports.experienceCurves = experienceCurves = [
	'medium-fast', 'erratic', 'fluctuating'
	'medium-slow', 'fast', 'slow'
]

exports.colors = colors = [
	'red', 'blue', 'yellow', 'green', 'black'
	'brown', 'purple', 'gray', 'white', 'pink'
]

exports.eggGroups = eggGroups = [
	null, 'monster', 'water-1', 'bug', 'flying', 'field'
	'fairy', 'grass', 'human-like', 'water-3', 'mineral'
	'amorphous', 'water-2', 'ditto', 'dragon', 'undiscovered'
]

exports.readEntries = (buffer) ->
	length = buffer.length // baseDataSize

	for i in [0...length]
		structBuf = buffer.slice i * baseDataSize, (i+1) * baseDataSize

		exports.read structBuf

exports.read = (buffer) ->
	baseStats = {}
	for stat, i in statNames
		baseStats[stat] = buffer.readUInt8 0x00 + i

	type1 = types[buffer.readUInt8 0x06]
	type2 = types[buffer.readUInt8 0x07]

	effortYield = {}
	effortYieldData = buffer.readUInt16LE 0x0A
	for stat, i in statNames
		effortYield[stat] = (effortYieldData >> (i * 2)) & 0b11

	items = [
		buffer.readUInt16LE 0x0C
		buffer.readUInt16LE 0x0E
	]

	colorFlip = buffer.readUInt8 0x19

	d = {
		baseStats
		types: if type1 is type2 then [type1, null] else [type1, type2]

		catchRate: buffer.readUInt8 0x08
		baseExperienceYield: buffer.readUInt8 0x09
		effortYield

		gender: buffer.readUInt8 0x10
		eggCycles: buffer.readUInt8 0x11
		baseFriendship: buffer.readUInt8 0x12

		experienceCurve: experienceCurves[buffer.readUInt8 0x13]
		eggGroups: [
			eggGroups[buffer.readUInt8 0x14]
			eggGroups[buffer.readUInt8 0x15]
		]

		abilities: [
			data.abilities[buffer.readUInt8 0x16]
			data.abilities[buffer.readUInt8 0x17]
		]

		safariFleeRate: buffer.readUInt8 0x18
		color: colors[colorFlip & 0b1111111]
		flipped: (colorFlip >> 7) is 1
	}

	## aliases
	if type1 is type2 then d.type = type1
	if not d.abilities[1]? then d.ability = d.abilities[0]
	if d.eggGroups[0] is d.eggGroups[1] then d.eggGroup = d.eggGroups[0]

	[commonItem, rareItem] = d.items = for item in items
		if Item.isNothing item then null else Item.readType item

	if commonItem? and rareItem is commonItem
		d.item = commonItem

	else if commonItem? then d.commonItem = commonItem
	else if rareItem? then d.rareItem = rareItem

	d