app   = require('express')()

transmissionConfig = require('./web-app/_config_transmission')

app.post '/torrents', transmissionConfig, (req, res, next) ->
  torrentUrl    = req.param 'torrent_url'
  download_dir  = req.param('download_dir') or req.transmissionConfig.download_dir

  console.log 'requesting to download_dir', download_dir
  require('../actions/add_torrent')(torrentUrl, {download_dir})
    .fail (error) ->
      res.status 500
      error
    .done (result) ->
      console.log 'responding with', result
      res.json result

module.exports = app