chai = require 'chai'

{expect} = chai
chai.should()

describe 'Text encoding', ->
	encoding = require '../src/text-encoding'

	describe '.toEncoded()', ->
		it 'should encode a single character to its corresponding byte', ->
			for i in [0...26]
				encoding.toEncoded(String.fromCharCode 65 + i).should.equal 0xBB + i
				encoding.toEncoded(String.fromCharCode 97 + i).should.equal 0xD5 + i

			for i in [0..9]
				encoding.toEncoded("#{i}").should.equal 0xA1 + i

	describe '.toDecoded()', ->
		it 'should decode a byte to its corresponding string', ->
			for i in [0...26]
				encoding.toDecoded(0xBB + i).should.equal String.fromCharCode 65 + i
				encoding.toDecoded(0xD5 + i).should.equal String.fromCharCode 97 + i

			for i in [0..9]
				encoding.toDecoded(0xA1 + i).should.equal "#{i}"

	describe '.encode()', ->
		it 'should encode alphanumerical symbols', ->
			str = 'JebzRoxx'
			data = [0xC4, 0xD9, 0xD6, 0xEE, 0xCC, 0xE3, 0xEC, 0xEC]

			[].slice.call(encoding.encode(str)).should.deep.equal data

		it 'should pad with 0xFF if input string shorter than len param', ->
			str = 'Jebz'
			data = [0xC4, 0xD9, 0xD6, 0xEE, 0xFF, 0xFF, 0xFF, 0xFF]

			[].slice.call(encoding.encode(str, 8)).should.deep.equal data

	describe '.decode()', ->
		it 'should decode alphanumerical symbols', ->
			buf = new Buffer [0xBB..0xD4]

			encoding.decode(buf).should.equal (
				[65..90]
				.map (n) -> String.fromCharCode n
				.join ''
			)

			buf = new Buffer [0xA1..0xAA]

			encoding.decode(buf).should.equal (
				[0..9]
				.map (n) -> "#{n}"
				.join ''
			)

			buf = new Buffer [0xC4, 0xD9, 0xD6, 0xEE, 0xCC, 0xE3, 0xEC, 0xEC]

			encoding.decode(buf).should.equal 'JebzRoxx'

		it 'should stop prematurely at a terminator symbol', ->
			buf = new Buffer [0xC4, 0xD9, 0xD6, 0xEE, 0xFF, 0xFF, 0xFF, 0xFF]

			decoded = encoding.decode buf

			decoded.should.have.length(4).and.equal 'Jebz'