async       = require 'async'
Q           = require 'q'
Config      = require('../db/config')
request     = require('request')
fs          = require 'fs'
readTorrent = Q.denodeify require('read-torrent')
E_TRACKER   = require('../errors').TRACKER

url     = require 'url'

cookies = request.jar()

authorizeAtTracker = Q.denodeify (config, callback) ->
  authUrl  = "http://login.rutracker.org/forum/login.php"

  postData = 
    login_username: config.login
    login_password: config.password
    login: "Вход"

  request {
    method             : "POST"
    form               : postData
    jar                : cookies
    url                : authUrl
  }, (error, response, bodyResult) ->
    callback error

__downloadFile = Q.denodeify (config, torrentId, callback) ->
  downloadUrl = "http://dl.rutracker.org/forum/dl.php?t=#{torrentId}"

  headers =
    'Content-Type':'application/x-www-form-urlencoded'
    't': torrentId
    'Referer': "http://rutracker.org/forum/viewtopic.php?t=#{torrentId}"


  postData =
    t: torrentId

  normalizePath = require('path').normalize

  torrentFilePath = normalizePath __dirname + "/../files/file.t#{torrentId}.torrent"

  stream = fs.createWriteStream(torrentFilePath)

  stream.on 'error', (error) ->
    callback error

  stream.on 'finish', ->
    console.log 'finished torrent downloading', torrentFilePath
    callback null, torrentFilePath

  request({
    method             : "POST"
    form               : postData
    headers            : headers
    url                : downloadUrl
    jar                : cookies
  }).pipe stream

_downloadFile = (config, torrentId) ->
  __downloadFile(config, torrentId)
    .then (filePath) ->
      readTorrent(filePath).then (parsedTorrentFile) ->
        console.log "torrent file is ok, assuming had logged in"
        filePath
    .fail (error) ->
      console.log 'failed to load torrent file', error
      throw E_TRACKER.CANT_AUTHORIZE()



downloadTorrent = (config, urlToTorrentTheme) ->
  parsedUrl = url.parse urlToTorrentTheme, yes
  torrentId = parsedUrl.query.t

  throw new Error "Cant find torrent id in url" unless torrentId

  _downloadFile(config, torrentId)
    .fail (error) ->
      if error and E_TRACKER.CANT_AUTHORIZE.is(error)
        authorizeAtTracker(config).then ->
          _downloadFile config, torrentId
      else
        throw error



module.exports = (urlToTorrentTheme) ->
  Config.get('tracker')
    .then (config) ->
      downloadTorrent config, urlToTorrentTheme
    .fail (error) ->
      console.log 'failed to download', error
      throw error