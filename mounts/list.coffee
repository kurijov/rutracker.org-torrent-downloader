app   = require('express')()
async = require('async')

app.post '/list', (req, res, next) ->
  require('../actions/sync_torrents')()
    .fail( (error) ->
      res.json 500, error
    )
    .done (result) -> res.json result

module.exports = app