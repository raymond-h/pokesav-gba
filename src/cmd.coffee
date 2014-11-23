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

{Savefile} = pokesavGba

save = new Savefile fs.readFileSync argv.file

console.log util.inspect save, depth: null