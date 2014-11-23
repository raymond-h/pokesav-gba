chai = require 'chai'

{expect} = chai
chai.should()

describe 'Experience', ->
	Experience = require '../src/Experience'

	it 'should default to 0 EXP for any level if unknown type', ->
		for lv in [0, 25, 50, 75, 100]
			Experience.calculate('unknown-curve', lv).should.equal 0

	testExpForLv = (type, expected) ->
		it 'should calculate the correct experience for level', ->
			(
				[lv, Experience.calculate(type, lv)] for [lv, exp] in expected
			)
			.should.deep.equal expected

	testLvForExp = (type, expected) ->
		it 'should calculate the correct level for experience', ->
			(
				[Experience.levelFromExperience(type, exp), exp] for [lv, exp] in expected
			)
			.should.deep.equal expected

	tests = (type, expected) ->
		testExpForLv type, expected
		testLvForExp type, expected

	describe 'Slow curve', ->
		tests 'slow', [
			[1, 0]
			[2, 10]
			[10, 1250]
			[50, 156250]
			[75, 527343]
			[100, 1250000]
		]

	describe 'Medium Slow curve', ->
		tests 'medium-slow', [
			[1, 0]
			[2, 9]
			[10, 560]
			[50, 117360]
			[75, 429235]
			[100, 1059860]
		]

	describe 'Medium Fast curve', ->
		tests 'medium-fast', [
			[1, 0]
			[2, 8]
			[10, 1000]
			[50, 125000]
			[75, 421875]
			[100, 1000000]
		]

	describe 'Fast curve', ->
		tests 'fast', [
			[1, 0]
			[2, 6]
			[10, 800]
			[50, 100000]
			[75, 337500]
			[100, 800000]
		]

	describe 'Erratic curve', ->
		tests 'erratic', [
			[1, 0]
			[2, 15]
			[10, 1800]
			[50, 125000]
			[75, 326531]
			[100, 600000]
		]

	describe 'Fluctuating curve', ->
		tests 'fluctuating', [
			[1, 0]
			[2, 4]
			[10, 540]
			[50, 142500]
			[75, 582187]
			[100, 1640000]
		]