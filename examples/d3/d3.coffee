fs = require('fs')
proto_client = require('../../src/__init__')
proto_game = require('proto-game')

client = new proto_client.program()

client.set_descriptor(fs.readFileSync('all.descriptor'))

client.rebind_network
	'network.process_id': 'bnet.protocol.connection.ProcessId'
	'network.service': 'bnet.protocol.connection.ConnectionService'
	'network.connect_request': 'bnet.protocol.connection.ConnectRequest'
	'network.connect_response': 'bnet.protocol.connection.ConnectResponse'
	'network.bind_request': 'bnet.protocol.connection.BindRequest'
	'network.bind_response': 'bnet.protocol.connection.BindResponse'
	'network.connection.service': 'bnet.protocol.connection.ConnectionService'
	'network.connection.null_request': 'bnet.protocol.connection.NullRequest'
	'network.connection.encrypt_request': 'bnet.protocol.connection.EncryptRequest'
	'network.authentication.logon_request': 'bnet.protocol.authentication.LogonRequest'
	'network.authentication.logon_response': 'bnet.protocol.authentication.LogonResponse'

client.add_service(new proto_game.network.service())
client.add_service(new proto_game.network.connection.service())
client.add_service(new proto_game.network.authentication.service())

client.add_plugin(new proto_client.plugin.connector())

client.run()