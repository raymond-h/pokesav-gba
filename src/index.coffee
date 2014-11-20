fs = require 'fs'
util = require 'util'
{argv} = require 'yargs'

GameSave = require './game-save'

saveA = new GameSave fs.readFileSync argv.file

console.log util.inspect saveA, depth: null