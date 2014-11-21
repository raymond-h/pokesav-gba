_ = require 'lodash'

data = require '../data/pokemon.json'

exports.itemEntryLength = itemEntryLength = 4

exports.nothing = 0x00000000

exports.isNothing = (item) ->
	switch
		when _.isObject item
			item.name is 'Nothing' or item.type is 0 or item.amount is 0

		when _.isString item
			item is 'Nothing'

		when _.isNumber item
			item is exports.nothing

		else false

exports.readType = (buffer, offset) ->
	if Buffer.isBuffer buffer
		exports.readType buffer.readUInt16LE offset
	
	else data.items[buffer]

exports.readItem = (buffer, offset, securityKey = 0) ->
	{
		name: exports.readType buffer, offset + 0x00
		amount: (buffer.readUInt16LE offset + 0x02) ^ (securityKey & 0xFFFF)
	}

exports.readList = (buffer, offset, numEntries, securityKey = 0) ->
	numEntries ?= Math.floor buffer.length / itemEntryLength

	for i in [0...numEntries]
		item = exports.readItem buffer, offset + i * itemEntryLength, securityKey

		break if exports.isNothing item

		item