app   = require('./main')

app.get '/torrents', (req, res, next) ->
  res.respond req.manager.sync_torrents()

module.exports = app