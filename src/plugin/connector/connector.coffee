net = require('net')
game = require('proto-game')
plugin = game.plugin
network = game.network

class connector extends plugin
	constructor: (@program) ->
		if @program
			@set_program(@program)
	
	set_program: (@program) ->
		@program.on 'initialized', () =>
			@connection_service = @program.get_service('connection')
			
			@program.on 'login', () =>
				game.debug.write('Connecting to game server (port: 1119).')
				
				@program.server = net.createConnection(1119, 'localhost')
				
				@program.server.on 'connect', (server) =>
					game.debug.write('Connected to game server.')
					
					game.debug.write('Sending a connect_request message.')
					
					client_id = new network.process_id()
					client_id.label = 10000
					client_id.epoch = (new Date()).getTime()
					
					m1 = new network.connection.connect_request()
					m1.client_id = client_id
					
					@connection_service.send 1, @program.server, m1, (r1) =>
						m1 = new network.connection.bind_request()
						m1.imported_service_hash = 'hash here'
						
						exported_service = new network.connection.bound_service()
						m1.exported_service = exported_service

						@connection_service.send 2, @program.server, m1, (r1) =>
				
				@program.server.on 'data', (message) =>
					[service_id, method_id, length, message] = @connection_service.receive message
					
					console.log 'Receiving: ', message, ' Service: ', service_id, 'Method: ', method_id, 'Length: ', length
	
	connection_service: null
	program: null
	
exports.connector = connector