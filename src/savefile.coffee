GameSave = require './game-save'

module.exports = class Savefile
	constructor: (buffer) ->
		@read buffer

	read: (buffer) ->
		saveA = new GameSave buffer.slice 0, 57344
		saveB = new GameSave buffer.slice 57344, 2*57344

		if saveA.saveIndex > saveB.saveIndex
			[@current, @previous] = [saveA, saveB]

		else [@current, @previous] = [saveB, saveA]