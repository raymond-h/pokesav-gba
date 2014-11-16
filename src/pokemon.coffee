textEncoding = require './text-encoding'
{languages} = require './constants'

module.exports = class Pokemon

	constructor: (buffer) ->
		@read buffer

	read: (buffer) ->
		@personalityValue = buffer.readUInt32LE 0x00
		@originalTrainerId = buffer.readUInt32LE 0x04

		@name = textEncoding.decode buffer.slice 0x08, 0x08+10

		@language = languages[buffer.readUInt16LE 0x12]

		@originalTrainerName = textEncoding.decode buffer.slice 0x14, 0x14+7