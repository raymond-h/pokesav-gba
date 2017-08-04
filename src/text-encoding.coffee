_ = require 'lodash'

exports.toEncoded = (char) ->
	switch
		when 'A' <= char <= 'Z'
			0xBB + (char.charCodeAt(0) - 65)

		when 'a' <= char <= 'z'
			0xD5 + (char.charCodeAt(0) - 97)

		when '0' <= char <= '9'
			0xA1 + (char.charCodeAt(0) - 48)

		else 0x00

exports.encode = (str, len = str.length) ->
	buf = new Buffer len
	(buf.writeUInt8 (exports.toEncoded c), i) for c,i in str
	buf.fill 0xFF, str.length, len
	buf

exports.toDecoded = (byte) ->
	switch
		when 0xBB <= byte <= 0xD4
			String.fromCharCode 65 + (byte - 0xBB)

		when 0xD5 <= byte <= 0xEE
			String.fromCharCode 97 + (byte - 0xD5)

		when 0xA1 <= byte <= 0xAA
			String.fromCharCode 48 + (byte - 0xA1)
			
		when 0xAB
			0x21
			
		when 0xAC
			0x3F
			
		when 0xAD
			0x2E
			
		when 0xAE
			0xAD
			
		when 0xB5
			0x2642
			
		when 0xB6
			0x2640

		else ' '

exports.decode = (buf, len = buf.length) ->
	chars = for b in buf
		break if b is 0xFF

		exports.toDecoded b
	
	chars.join ''