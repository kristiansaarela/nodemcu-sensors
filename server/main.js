var net = require('net')
var client = new net.Socket()
var config = require('./config.js')

client.connect(config.server_port, config.server_ip, function () {
	console.log('connected')

	client.write('hei mcu')
})

client.on('data', function (data) {
	console.log(data.toString())
	client.destroy()
})

client.on('close', function () {
	console.log('closed')
})
