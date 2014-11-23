_ = require 'lodash'

typeExpResolver = (type, exp) -> "#{type}-#{exp}"

exports.levelFromExperience = _.memoize (type, exp) ->
	if not (
		type in ['slow','medium-slow','medium-fast','fast','erratic','fluctuating']
	)

		return -1

	level = 0

	while (exports.calculate type, level+1) <= exp
		level++

	level

, typeExpResolver

exports.calculate = (type, minLvl) ->
	(exports.growthRateFunctions[type]? minLvl) ? 0

exports.growthRateFunctions =
	'slow': (n) -> if n <= 1 then 0 else ( 5 * n**3 // 4 )

	'medium-slow': (n) ->
		if n <= 1 then 0
		else Math.floor(  (6/5) * n**3 - 15 * n*n + 100*n - 140 )

	'medium-fast': (n) -> if n <= 1 then 0 else ( n**3 )

	'fast': (n) -> 4 * n**3 // 5

	'erratic': (n) -> switch
		when n <= 1 then 0

		when n <= 50 then (n**3 * (100 - n)) // 50

		when 50 <= n <= 68 then (n**3 * (150 - n)) // 100

		when 68 <= n <= 98 then ( n**3 * ((1911 - 10*n) // 3) ) // 500

		when 98 <= n then (n**3 * (160 - n)) // 100

	'fluctuating': (n) -> Math.floor switch
		when n <= 15 then n**3 * ( (n+1) // 3 + 24 ) / 50

		when 15 <= n <= 36 then n**3 * ( (n + 14) / 50 )

		when 36 <= n then n**3 * ( (n // 2 + 32) / 50 )