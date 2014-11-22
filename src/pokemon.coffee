textEncoding = require './text-encoding'
{languages} = require './constants'
dataEncryption = (require './encryption').pokemonData
Item = require './item'

data = require '../data/pokemon.json'
pkmnBaseData = require '../data/base-data.json'

module.exports = class Pokemon

	@marking =
		circle: 0b0001
		box: 0b0010
		triangle: 0b0100
		heart: 0b1000

	statNames: ['hp', 'atk', 'def', 'spd', 'spAtk', 'spDef']

	constructor: (buffer) ->
		@read buffer

		Object.defineProperties @,
			# alias exp to experience
			exp:
				enumerable: no
				get: => @experience
				set: (exp) => @experience = exp

			# calculate level from/to exp automatically (not impl.)
			level:
				enumerable: yes
				get: => undefined
				set: (lvl) => undefined

	read: (buffer) ->
		@personalityValue = buffer.readUInt32LE 0x00
		@originalTrainerId = buffer.readUInt32LE 0x04

		@name = textEncoding.decode buffer.slice 0x08, 0x08+10

		@language = languages[buffer.readUInt16LE 0x12]

		@originalTrainerName = textEncoding.decode buffer.slice 0x14, 0x14+7

		@markings = buffer.readUInt32LE 0x1B

		dataChecksum = buffer.readUInt16LE 0x1C
		pkmnData = dataEncryption.decrypt(
			# encryption key
			@originalTrainerId ^ @personalityValue

			# actual slice of data
			buffer.slice 0x20, 0x20 + 48
		)

		# TODO: verify checksum

		@readData pkmnData

	calculateDataOrder: ->
		orderNum = @personalityValue % 24

		baseOrder = ['growth', 'attacks', 'evsCondition', 'misc']

		order = []
		for i in [orderNum // 6, (orderNum % 6) // 2, orderNum % 2]
			order.push baseOrder[i]
			baseOrder[i..i] = []

		order.push baseOrder[0]

		order

	readData: (buffer) ->
		for substructType, i in @calculateDataOrder()
			substructSlice = buffer.slice i * 12, (i+1) * 12

			switch substructType
				when 'growth' then @readGrowth substructSlice
				when 'attacks' then @readAttacks substructSlice
				when 'evsCondition' then @readEvsCondition substructSlice
				when 'misc' then @readMisc substructSlice

		baseData = pkmnBaseData[@speciesIndex]

		@ability = baseData.ability ? baseData.abilities[@ability]

	readGrowth: (buffer) ->
		@speciesIndex = buffer.readUInt16LE 0x0
		@species = data.pokemon[@speciesIndex]

		heldItem = buffer.readUInt16LE 0x2
		@heldItem = Item.readType heldItem if not Item.isNothing heldItem

		@experience = buffer.readUInt32LE 0x4

		ppBonuses = buffer.readUInt8 0x8
		@ppBonuses = [
			ppBonuses & 0b00000011
			ppBonuses & 0b00001100
			ppBonuses & 0b00110000
			ppBonuses & 0b11000000
		]

		@friendship = buffer.readUInt8 0x9

		# save this, for writing later if needed
		@_unknownGrowthBytes = buffer.readUInt16LE 0xA

	readAttacks: (buffer) ->
		readMove = (index) ->
			move = buffer.readUInt16LE 0x0 + index * 2
			return null if move is 0

			name: data.moves[move]
			pp: buffer.readUInt8 0x8 + index

		@moves = for i in [0...4]
			move = readMove i
			break if not move?

			move

	readEvsCondition: (buffer) ->
		conditions = ['coolness', 'beauty', 'cuteness', 'smartness', 'toughness']

		@evs = {}
		for stat,i in @statNames
			@evs[stat] = buffer.readUInt8 0x0 + i

		@condition = {}
		for cond,i in conditions
			@condition[cond] = buffer.readUInt8 0x6 + i

		@feel = buffer.readUInt8 0xB

	readMisc: (buffer) ->
		@pokerusStatus = buffer.readUInt8 0x0
		@metLocation = buffer.readUInt8 0x1
		@originInfo = buffer.readUInt16LE 0x2

		ivsEggAbilityData = buffer.readUInt32LE 0x4

		@ivs = {}
		for stat,i in @statNames
			@ivs[stat] = (ivsEggAbilityData >> (i * 5)) & 0b11111

		@isEgg = (ivsEggAbilityData >> 30) & 0b1

		@ability = (ivsEggAbilityData >> 31) & 0b1