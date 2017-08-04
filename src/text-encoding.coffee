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
			
		when byte is 0xAB
			'!'
			
		when byte is 0xAC
			'?'
			
		when byte is 0xAD
			'.'
			
		when byte is 0xAE
			'-'
			
		when byte is 0xAF
			'・'
			
		when byte is 0xB0
			'…'
			
		when byte is 0xB5
			'♂'
			
		when byte is 0xB6
			'♀'
			
		when 0x01 <= byte <= 0x03
			String.fromCharCode 192 + (byte - 0x01)
			
		when 0x04 <= byte <= 0x0C and byte != 0x0A
			String.fromCharCode 199 + (byte - 0x04)
			
		when 0x0D <= byte <= 0x0F
			String.fromCharCode 210 + (byte - 0x0D)
			
		when byte is 0x10
			'Œ'
			
		when 0x11 <= byte <= 0x13
			String.fromCharCode 217 + (byte - 0x11)
			
		when byte is 0x14
			'Ñ'
			
		when byte is 0x15
			'ß'
			
		when 0x16 <= byte <= 0x17
			String.fromCharCode 224 + (byte - 0x16)
			
		when 0x19 <= byte <= 0x21 and byte != 0x1F
			String.fromCharCode 231 + (byte - 0x19)
			
		when 0x22 <= byte <= 0x24
			String.fromCharCode 242 + (byte - 0x22)
			
		when byte is 0x25
			'œ'
			
		when 0x26 <= byte <= 0x28
			String.fromCharCode 249 + (byte - 0x26)
			
		when byte is 0x29
			'ñ'
			
		when byte is 0x2A
			'º'
			
		when byte is 0x2B
			'ª'
			
		when byte is 0x2D
			'&'
			
		when byte is 0x2E
			'+'
			
		when byte is 0x35
			'='
			
		when byte is 0x36
			';'
			
		when byte is 0x50
			'▯'
			
		when byte is 0x51
			'¿'
			
		when byte is 0x52
			'¡'
			
		when byte is 0x5A
			'Í'
			
		when byte is 0x5B
			'%'
			
		when 0x5C <= byte <= 0x5D
			String.fromCharCode 40 + (byte - 0x5C)
			
		when byte is 0x68
			'â'
			
		when byte is 0x6F
			'í'
			
		when byte is 0x79
			'↑'
			
		when byte is 0x7A
			'↓'
		
		when byte is 0x7B
			'←'
		
		when byte is 0x7C
			'→'
			
		when 0x7D <= byte <= 0x83
			'*'
			
		when byte is 0x84
			'ᵉ'
			
		when byte is 0x85
			'<'
			
		when byte is 0x86
			'>'
			
		when 0xB1 <= byte <= 0xB2
			String.fromCharCode 8220 + (byte - 0xB1)
			
		when 0xB3 <= byte <= 0xB4
			String.fromCharCode 8216 + (byte - 0xB3)
			
		when byte is 0xB8
			','
			
		when byte is 0xB9
			'×'
			
		when byte is 0xBA
			'/'
			
		when byte is 0xEF
			'▶'
			
		when byte is 0xF0
			':'
			
		when byte is 0xF1
			'Ä'
			
		when byte is 0xF2
			'Ö'
			
		when byte is 0xF3
			'Ü'
			
		when byte is 0xF4
			'ä'
			
		when byte is 0xF5
			'ö'
			
		when byte is 0xF6
			'ü'

		else ' '

exports.decode = (buf, len = buf.length) ->
	chars = for b in buf
		break if b is 0xFF

		exports.toDecoded b
	
	chars.join ''