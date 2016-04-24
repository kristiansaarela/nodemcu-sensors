var config = require('./config.js')
var nano = require('nano')(config.couchdb)

function prepare (doc) {
	for (key in doc) {
		if (key[0] != '_') {
			if (typeof doc[key] == 'function') {
				doc[key] = doc[key].toString()
			}
			if (typeof doc[key] == 'object') {
				prepare(doc[key])
			}
		}
	}
}

var design_views = [
	{
		'_id': '_design/dht',
		'views': {
			list: {
				map: function (doc) {
					if (doc.type && doc.type == 'dht') {
						emit(doc._id, doc)
					}
				}
			}
		}
	}
]

function install_db (cb) {
	nano.db.list(function (err, list) {
		if (!err && list.indexOf(config.couchdb.database) === -1) {
			nano.db.create(config.couchdb.database, function (err) {
				if (err) {
					return cb && cb(err)
				}
			})
		}
		return cb && cb(err)
	})
}

install_db(function (err) {
	if (err && err.error != 'file_exists') {
		return console && console.error('Couldn\'t create database', err)
	}

	var db = nano.use(config.couchdb.database)

	design_views.forEach(function (doc) {
		prepare(doc)

		if (!doc._id) {
			console && console.error('Document ID is missing', doc)
		} else {
			db.get(doc._id, function(err, item) {
				if (!err) {
					doc._rev = item._rev
				}

				db.insert(doc, function(err) {
					if (err) {
						console.error('Failed to insert design document', doc)
					}
				})
			})
		}
	})

	console.info('All ok')
})
