chai = require 'chai'

{expect} = chai
chai.should()

describe 'Util', ->
	util = require '../src/util'

	describe '.to1DArray', ->
		it 'should return a simple value as an array with 1 item', ->
			value = 5
			util.to1DArray(value).should.deep.equal [5]

		it 'should return an array with no nested arrays as-is', ->
			value = [5, 9]
			util.to1DArray(value).should.deep.equal [5, 9]

		it 'should flatten an array with one or more nested arrays', ->
			value = [5, 9, [80, 12]]
			util.to1DArray(value).should.deep.equal [5, 9, 80, 12]

	describe '.alias', ->
		it 'should alias the given properties on a given object', ->
			obj =
				fast: 8
				medium: /5m/
				slow: '2m/s'

			util.alias obj, 'slow', 's'

			obj.s.should.equal obj.slow

			util.alias obj, 'medium', 'm', 'hastily'

			obj.m.should.equal obj.medium
			obj.hastily.should.equal obj.medium

			util.alias obj, 'fast', ['f', 'quick']
			
			obj.f.should.equal obj.fast
			obj.quick.should.equal obj.fast