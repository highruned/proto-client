fs = require('fs')
proto_client = require('../../src/__init__')
proto_game = require('proto-game')

client = new proto_client.program()

client.set_descriptor(fs.readFileSync('all.descriptor'))

client.rebind_network
	'network.process_id': 'bnet.protocol.connection.ProcessId'
	'network.connection.service': 'bnet.protocol.connection.ConnectionService'
	'network.connection.connect_request': 'bnet.protocol.connection.ConnectRequest'
	'network.connection.connect_response': 'bnet.protocol.connection.ConnectResponse'

connection_service = new proto_game.network.connection.service()

client.add_service(connection_service)

client.add_plugin(new proto_client.plugin.connector())

client.run()