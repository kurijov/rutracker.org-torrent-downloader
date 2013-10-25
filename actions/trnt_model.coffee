persist = require('persist')
Q = require 'q'
type = persist.type

Torrent = persist.define "Torrent",
  t_id          : type.INTEGER
  hash          : type.STRING
  name          : type.STRING
  tracker_title : type.STRING
  torrent_url   : type.STRING
  download_dir  : type.STRING
  checked_at    : type.DATETIME

DDL = """
  CREATE TABLE IF NOT EXISTS `Torrents` (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    t_id INT,
    hash TEXT,
    name TEXT,
    tracker_title TEXT,
    torrent_url TEXT,
    download_dir TEXT,
    checked_at DATETIME
  );
"""

connectionObject = null

persist.connect {
  driver: 'sqlite3',
  filename: __dirname + '/../trntsdb.db',
  trace: no
}, (error, connection) ->
  # console.log error, connection
  connection.runSql DDL, [], (error, result) ->
    console.log 'DDL: ->', error, result
    connectionObject = connection

fnCheck = (callback) ->
  check = ->
    if connectionObject
      callback()
    else
      setTimeout ->
        check()
      , 50

  check()

module.exports = ->
  query: Torrent.using(connectionObject)
  model: Torrent
  connection: connectionObject
  ready: fnCheck
  readyQ: Q.denodeify(fnCheck)

