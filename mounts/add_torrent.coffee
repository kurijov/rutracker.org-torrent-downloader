app   = require('express')()
async = require('async')

app.post '/add', (req, res, next) ->
  torrentUrl    = req.param 'url'
  download_dir  = req.param 'download_dir'

  async.waterfall [
    (callback) -> require('../actions/add_torrent') torrentUrl, {download_dir}, callback
  ], (error, result) ->
    if error
      res.json 500, error
    else
      res.json result

module.exports = app