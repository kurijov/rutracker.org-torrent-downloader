app   = require('./main')

app.get '/torrents', (req, res, next) ->
  res.respond req.manager.sync_torrents()

app.post '/torrents', (req, res, next) ->
  torrentUrl    = req.param 'torrent_url'

  req.respond req.manager.add_torrent(torrentUrl, {
    download_dir: req.param('download_dir')
  })