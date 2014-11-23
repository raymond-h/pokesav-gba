_ = require 'lodash'

exports.to1DArray = (array) -> _.flatten [].concat array

exports.alias = (obj, srcProp, destProps...) ->
	destProps = exports.to1DArray destProps

	for dest in destProps
		Object.defineProperty obj, dest,
			enumerable: no
			get: -> @[srcProp]
			set: (val) -> @[srcProp] = val