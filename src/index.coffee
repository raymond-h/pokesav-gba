fs = require 'fs'
{argv} = require 'yargs'

GameSave = require './game-save'

saveA = new GameSave fs.readFileSync argv.file

console.log saveA