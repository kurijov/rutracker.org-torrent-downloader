db = require '../db'
Q  = require 'q'

DDLs = []
DDLs.push """
  CREATE TABLE IF NOT EXISTS `Torrents` (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    t_id INT,
    hash TEXT,
    name TEXT,
    tracker_title TEXT,
    torrent_url TEXT,
    download_dir TEXT,
    checked_at DATETIME,
    in_job INT DEFAULT 0
  );
"""

DDLs.push """
  CREATE TABLE IF NOT EXISTS `Config` (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    path TEXT,
    value TEXT
  );
"""


db
  .then (connection) ->
    Q.all (Q.ninvoke connection, 'runSqlAll', ddl for ddl in DDLs)
  .then ->
    console.log "DB: installed"
  , (error) ->
    console.log 'Failed to install DB'
    console.log error
    throw error
  .done()