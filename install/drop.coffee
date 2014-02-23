db = require '../db'
Q  = require 'q'

DDLs = []
DDLs.push """
  DROP TABLE `Torrents`;
"""

DDLs.push """
  DROP TABLE `Config`;
"""


db
  .then (connection) ->
    Q.all (Q.ninvoke connection, 'runSqlAll', ddl for ddl in DDLs)
  .then ->
    console.log "DB: dopped"
  , (error) ->
    console.log 'Failed to drop DB'
    console.log error
    throw error
  .done()