app   = require('express')()

app.del '/torrents/:torrentId', (req, res, next) ->
  torrentId    = req.param 'torrentId'

  require('../actions/remove_torrent')(torrentId)
    .fail (error) ->
      res.status 500
      error
    .done (result) ->
      console.log 'giving response', result
      res.json result

module.exports = app