module.exports =
	size: 4096

	split: (buffer) ->
		data: buffer.slice 0, 4080
		id: buffer.readUInt16LE 0x0FF4
		checksum: buffer.readUInt16LE 0x0FF6
		saveIndex: buffer.readUInt32LE 0x0FFC