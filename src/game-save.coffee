_ = require 'lodash'
Section = require './section'

module.exports = class GameSave
	constructor: (buffer) ->
		@saveIndex = -1

		@read buffer

	read: (buffer) ->
		for i in [0...14]
			sectionBuffer = buffer.slice i * Section.size, (i+1) * Section.size

			section = Section.split sectionBuffer
			@parsers[section.id]?.apply @, section

	parsers: {}