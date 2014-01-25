app   = require('./main')

app.get '/torrents', (req, res, next) ->
  res.respond req.manager.sync_torrents()

app.post '/torrents', (req, res, next) ->
  torrentUrl    = req.param 'torrent_url'

  res.respond req.manager.add_torrent(torrentUrl, {
    download_dir: req.param('download_dir')
  })

app.get '/torrents/check/:id', (req, res, next) ->
  if req.param('id')
    res.respond req.manager.check_torrent req.param('id')
  else
    res.respond req.manager.checkTorrents()