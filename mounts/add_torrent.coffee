app   = require('express')()
async = require('async')

app.post '/torrents', (req, res, next) ->
  torrentUrl    = req.param 'url'
  download_dir  = req.param 'download_dir'

  require('../actions/add_torrent')(torrentUrl, {download_dir})
    .fail (error) ->
      res.status 500
      error
    .done (result) ->
      console.log 'giving response', result
      res.json result

module.exports = app