Q       = require 'q'
persist = require 'persist'

config = require('../config')

module.exports = Q.ninvoke persist, 'connect', {
  driver   : 'sqlite3',
  filename : config.db.filename,
  trace    : no
}