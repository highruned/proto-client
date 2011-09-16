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
			@default_service = @program.get_service('default')
			
			@program.on 'login', () =>
				game.debug.write('Connecting to game server (port: 1119).')
				
				@program.server = net.createConnection(1119, 'localhost')
				
				@program.server.on 'connect', (server) =>
					game.debug.write('Connected to game server.')
					
					game.debug.write('Sending a connect_request message.')
					
					client_id = new network.process_id
						label: 10000
						epoch: (new Date()).getTime()
					
					connect_request = new network.connect_request
					
					@default_service.send 
						method_id: 1
						endpoint: @program.server
						message: connect_request
						call: (result) =>
							bind_request = new network.bind_request()
							
							# tell the server we HAVE a connection and authentication service to bind
							bind_request.imported_service_hash = [
								@program.get_service('connection').hash,
								@program.get_service('authentication').hash
							]
							
							connection_service = new network.bound_service
								hash: @program.get_service('connection').hash
								id: @program.get_service('connection').id
								
							authentication_service = new network.bound_service
								hash: @program.get_service('connection').hash
								id: @program.get_service('connection').id
							
							# tell the server we WANT to bind a connection and authentication service
							bind_request.exported_service = [
								connection_service,
								authentication_service
							]
							
							@default_service.send
								method_id: 2
								endpoint: @program.server
								message: bind_request
								call: (result) =>
									@authentication_service = @program.get_service('authentication')
									
									logon_request = new network.authentication.logon_request
										program: 'D3'
										platform: 'Win'
										locale: 'enUS'
										email: 'test@account.com'
										listener_id: 23;
										version: 'Aurora 396b8632a7_public/188 (Aug 31 2011 20:25:07)'
  
									@authentication_service.send
										method_id: 3
										endpoint: @program.server
										message: logon_request
										call: (result) =>
											console.log result.message
				
				@program.server.on 'data', (message) =>
					service_id = message[0]
					
					@program.services[@program.get_service_by_id(service_id).name].receive
						endpoint: @program.server
						message: message.slice(1)
					
	default_service: null
	connection_service: null
	program: null
	
exports.connector = connector