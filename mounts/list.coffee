app   = require('express')()
async = require('async')

app.post '/list', (req, res, next) ->
  async.waterfall [
    (callback) -> require('../actions/sync_torrents') callback
  ], (error, result) ->
    if error
      res.json 500, error
    else
      res.json result

module.exports = app