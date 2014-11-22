fs = require 'fs'
util = require 'util'
argv = require 'yargs'
	.alias 'b', 'baseStatsFile'
	.argv

if argv.baseStatsFile?
	BaseDataReader = require './base-data'

	data = BaseDataReader.readEntries fs.readFileSync argv.baseStatsFile
	console.log JSON.stringify data

	return

GameSave = require './game-save'

saveA = new GameSave fs.readFileSync argv.file

console.log util.inspect saveA, depth: null