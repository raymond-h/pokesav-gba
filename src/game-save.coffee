_ = require 'lodash'

Section = require './section'
textEncoding = require './text-encoding'

module.exports = class GameSave
	constructor: (buffer) ->
		@saveIndex = -1

		@read buffer

		Object.defineProperties @,
			publicId:
				enumerable: no
				get: => @trainerId & 0xFFFF

			privateId:
				enumerable: no
				get: => (@trainerId & 0xFFFF0000) >> 16

	read: (buffer) ->
		for i in [0...14]
			sectionBuffer = buffer.slice i * Section.size, (i+1) * Section.size

			section = Section.split sectionBuffer
			@parsers[section.id]?.call @, section.data

			@saveIndex = section.saveIndex

	parsers:
		0: (data) ->
			@name = textEncoding.decode data.slice 0x00, 0x00 + 7
			@gender = if (data.readUInt8 0x08) is 0 then 'male' else 'female'
			@trainerId = data.readUInt32LE 0x0A

			@timePlayed =
				hours: data.readUInt16LE 0x0E
				minutes: data.readUInt8 0x0E+2
				seconds: data.readUInt8 0x0E+3
				frames: data.readUInt8 0x0E+4

			gameCode = data.readUInt32LE 0xAC

			switch gameCode
				when 0
					# ruby/sapphire
					@game = 'ruby-sapphire'
					@securityKey = 0x00 # 0 xor x = x

				when 1
					# firered / leafgreen
					@game = 'firered-leafgreen'
					@securityKey = data.readUInt32LE 0x0AF8

				else
					# emerald
					@game = 'emerald'
					@securityKey = gameCode