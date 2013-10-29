app   = require('express')()
async = require('async')

app.get '/list', (req, res, next) ->
  require('../actions/sync_torrents')()
    .fail (error) ->
      res.status 500
      error
    .done (result) -> res.json result

module.exports = app