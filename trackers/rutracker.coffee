class Rutracker
  download_torrent: (url) -> require('./rutracker/download_torrent')(url)

  get_torrent_title: (url) -> require('./rutracker/get_torrent_title')(url)

module.exports = Rutracker