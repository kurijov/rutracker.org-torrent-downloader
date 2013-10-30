Q = require 'q'
persist = require 'persist'

module.exports = Q.ninvoke persist, 'connect', {
  driver: 'sqlite3',
  filename: __dirname + '/trntsdb.db',
  trace: no
}