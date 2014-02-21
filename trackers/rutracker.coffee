Config      = require '../db/config'
request     = require('request')
Q           = require 'q'
url         = require 'url'
fs          = require 'fs'

E_TRACKER   = require('../errors').TRACKER

readTorrent = Q.denodeify require('read-torrent')

cookies = request.jar()

class Rutracker
  constructor: ->
    @authorized = no

  getConfig: -> Config.get('tracker')

  _download_torrent_file: (torrentId) ->
    deferred = Q.defer()

    downloadUrl = "http://dl.rutracker.org/forum/dl.php?t=#{torrentId}"

    headers =
      'Content-Type':'application/x-www-form-urlencoded'
      't': torrentId
      'Referer': "http://rutracker.org/forum/viewtopic.php?t=#{torrentId}"


    postData =
      t: torrentId

    normalizePath = require('path').normalize

    torrentFilePath = normalizePath __dirname + "/../../files/file.t#{torrentId}.torrent"

    stream = fs.createWriteStream(torrentFilePath)

    stream.on 'error', (error) ->
      deferred.reject E_TRACKER.CANT_DOWNLOAD_FILE({info: error.message})

    stream.on 'finish', ->
      console.log 'finished torrent downloading', torrentFilePath
      # callback null, torrentFilePath
      deferred.resolve(torrentFilePath)

    request({
      method             : "POST"
      form               : postData
      headers            : headers
      url                : downloadUrl
      jar                : cookies
    }).pipe stream

    deferred.promise


  authorize: ->
    if @authorized
      Q()
    else
      @_authorize().then =>
        @authorized = yes

  _post_auth_data: (requestData) ->
    deferred = Q.defer()

    request requestData, (error, response, bodyResult) ->
      return deferred.reject(error) if error

      deferred.resolve bodyResult

    deferred.promise

  _authorize: ->
    @getConfig()
      .then (config) =>
        return Q.reject(E_TRACKER.NO_LOGIN()) unless config.login
        return Q.reject(E_TRACKER.NO_PASS()) unless config.password

        authUrl  = "http://login.rutracker.org/forum/login.php"

        postData = 
          login_username : config.login
          login_password : config.password
          login          : "Вход"

        @_post_auth_data {
          method             : "POST"
          form               : postData
          jar                : cookies
          url                : authUrl
        }

      .then (bodyResult) ->
        htmlSaysThatUserIsNotLoggedIn = 'action="http://login.rutracker.org/forum/login.php"'

        if bodyResult.indexOf(htmlSaysThatUserIsNotLoggedIn) > -1
          Q.reject E_TRACKER.CANT_AUTHORIZE()
        else
          {authorized: 1}

  download_torrent: (urlToTorrentTheme) -> 
    parsedUrl = url.parse urlToTorrentTheme, yes
    torrentId = parsedUrl.query.t

    return Q.reject "Cant find torrent id in url" unless torrentId

    @authorize()
      .then =>
        @_download_torrent_file torrentId
      .then (path) =>
        @check_torrent_file path

  check_torrent_file: (filePath) ->
    fileOk = ->
      filePath

    fileBad = ->
      Q.reject E_TRACKER.BAD_FILE()

    @_check_torrent_file(filePath).then fileOk, fileBad

  _check_torrent_file: (filePath) -> readTorrent(filePath)

  get_torrent_title: (url) -> require('./rutracker/get_torrent_title')(url)

module.exports = Rutracker