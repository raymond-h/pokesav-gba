Pokemon = require './pokemon'
textEncoding = require './text-encoding'

class exports.PcStorage
	constructor: (buffer) ->
		@read buffer

	read: (buffer) ->
		@currentBoxIndex = buffer.readUInt32LE 0x0000

		@boxes = for i in [0...14]
			boxBuf = buffer.slice 0x0004 + i * 80 * 30, 0x0004 + (i+1) * 80 * 30

			name = textEncoding.decode buffer.slice 0x8344 + i * 9, 0x8344 + (i+1) * 9

			wallpaper = buffer.readUInt8 0x83C2 + i

			new exports.Box name, wallpaper, boxBuf

class exports.Box
	constructor: (@name, @wallpaper, buffer) ->
		@read buffer

	read: (buffer) ->
		@pokemon = for i in [0...30]
			Pokemon.fromBuffer buffer.slice i * 80, (i+1) * 80

	@calcPos: (x, y) -> y * 30 + x

	at: (x, y = null) ->
		if y? then x = exports.Box.calcPos x, y

		@pokemon[x]

	setAt: (x, y = null, pkmn) ->
		if not pkmn? then [pkmn, y] = [y, null]

		if y? then x = exports.Box.calcPos x, y

		@pokemon[x] = pkmn