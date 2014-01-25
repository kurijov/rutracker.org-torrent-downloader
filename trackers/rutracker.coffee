Config = require '../db/config'

class Rutracker
  getConfig: -> Config.get('tracker')

  download_torrent: (url) -> require('./rutracker/download_torrent')(url)

  get_torrent_title: (url) -> require('./rutracker/get_torrent_title')(url)

module.exports = Rutracker