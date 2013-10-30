db = require '../db'

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

db
  .then (connection) ->
    connection.runSqlAll DDL, (error) ->
      if error
        console.log error
      else
        console.log "Installed db: ok"
  .done()