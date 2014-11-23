fs = require 'fs'
util = require 'util'
argv = require 'yargs'
	.alias 'b', 'baseStatsFile'
	.argv

pokesavGba = require './index'

if argv.baseStatsFile?
	{BaseDataReader} = pokesavGba

	data = BaseDataReader.readEntries fs.readFileSync argv.baseStatsFile
	console.log JSON.stringify data

	return

{GameSave} = pokesavGba

saveA = new GameSave fs.readFileSync argv.file

console.log util.inspect saveA, depth: null