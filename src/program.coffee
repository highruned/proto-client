net = require('net')
game = require('proto-game')

class program extends game.program
	constructor: () ->
		super()
	
	run: () ->
		@emit 'initialized'
		
		@emit 'login'
			
	server: null
	config: {}
	
exports.program = program