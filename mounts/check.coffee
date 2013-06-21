app   = require('express')()
async = require('async')

app.post '/check', (req, res, next) ->

  async.waterfall [
    (callback) -> require('../actions/torrent_checker').checkNow callback
  ], (error, result) ->
    if error
      res.json 500, error
    else
      res.json result

module.exports = app