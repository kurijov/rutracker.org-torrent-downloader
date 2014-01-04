app   = require('express')()
async = require('async')

app.get '/torrents', (req, res, next) ->
  require('../actions/sync_torrents')()
    .fail (error) ->
      res.status 500
      error
    .done (result) -> 
      console.log 'responding with', result
      res.json result

module.exports = app