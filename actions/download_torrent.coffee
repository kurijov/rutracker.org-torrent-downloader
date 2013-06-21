apiCall = require('./api')
async   = require 'async'
request = require 'request'
fs      = require 'fs'

url     = require 'url'

downloadTorrent = (urlToTorrentTheme, callback, stop = no) ->
  parsedUrl = url.parse urlToTorrentTheme, yes
  torrentId = parsedUrl.query.t

  return callback "Cant find torrent id in url" unless torrentId

  async.waterfall [
    (callback) -> require('./acquire-cookies') callback
    (cookieList, callback) ->
      j        = request.jar()
      
      j.add request.cookie("bb_dl=#{torrentId}")
      for cookieItem in cookieList
        j.add request.cookie(cookieItem)

      data = 
        url: "http://dl.rutracker.org/forum/dl.php?t=#{torrentId}"
        jar: j
        method: 'POST'
        encoding: null
        headers: 
          "Host"       :"dl.rutracker.org"
          "Referer"    :urlToTorrentTheme
          "User-Agent" :"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.110 Safari/537.36"

      request data, callback

    (response, result, callback) ->
      torrentFilePath = __dirname + "/../files/newtorrent.#{torrentId}.torrent"

      if result.length is 0
        return callback "I couldnt download torren file" if stop

        async.waterfall [
          (callback) -> require('./acquire-cookies') yes, callback
          (cookies, callback) -> downloadTorrent urlToTorrentTheme, callback, yes
        ], callback
      else
        fs.writeFileSync torrentFilePath, result
        callback null, torrentFilePath

  ], callback

module.exports = downloadTorrent