var net = require('net')
var client = new net.Socket()
var moment = require('moment')
var config = require('./config.js')

var nano = require('nano')(config.couchdb)
var db = nano.use(config.couchdb.database)

client.connect(config.server.port, config.server.url)

client.on('data', function (response) {
	console.log(response.toString())
	response = response.toString()

	if (response.indexOf(',') !== -1) {
		response = response.split(',')

		var data = {
			type: 'dht',
			temp: response[0],
			humi: response[1],
			timestamp: moment().utc().format('X'),
		}
	} else {
		var data = {
			type: 'error',
			message: response,
		}
	}

	db.insert(data)
})

client.on('close', function () {
	console.log('Byebye!')
})
