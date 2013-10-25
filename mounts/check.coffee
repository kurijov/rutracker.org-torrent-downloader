app   = require('express')()
async = require('async')

app.post '/check', (req, res, next) ->
  require('../actions/torrent_checker').checkNow()
    .fail( (error) ->
      res.status 500
      error
    )
    .done (result) ->
      console.log 'giving response', result
      res.json result
  
module.exports = app