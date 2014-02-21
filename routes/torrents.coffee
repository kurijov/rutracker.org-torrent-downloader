app   = require('./main')

app.get '/torrents', (req, res, next) ->
  res.respond req.manager.sync_torrents()

app.post '/torrents', (req, res, next) ->
  torrentDescription    = req.param 'torrent_url'

  [stuff..., folder, url] = torrentDescription.match /(\{d:([^\}]+)\})?(.*)/

  res.respond req.manager.add_torrent(url, {
    folder: folder
  })

app.get '/torrents/check/:id', (req, res, next) ->
  if req.param('id')
    res.respond req.manager.check_torrent req.param('id')
  else
    res.respond req.manager.checkTorrents()

app.del '/torrents/:id', (req, res, next) ->
  res.respond req.manager.remove_torrent(req.param('id'))