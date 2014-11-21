xorAt = (encryptionKey, buffer, offset) ->
	buffer.writeInt32LE (encryptionKey ^ (buffer.readInt32LE offset)), offset

module.exports =
	pokemonData:
		decrypt: (encryptionKey, buffer) ->
			xorAt encryptionKey, buffer, i for i in [0...buffer.length] by 4

			buffer

		# encryption algo. is exact same as decryption algo.
		encrypt: (a...) -> module.exports.pokemonData.decrypt a...