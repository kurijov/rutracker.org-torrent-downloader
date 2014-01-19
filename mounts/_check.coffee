app     = require('express')()
Torrent = require('../db/torrent')
# async = require('async')

app.get '/torrents/check/:id', (req, res, next) ->
  if req.param('id')
    Torrent.getById(req.param('id'))
      .then (item) ->
        console.log 'item to check', item
        require('../actions/torrent_checker').checkItem(item)
      .then ->
        Torrent.getById(req.param('id'))
      .fail (error) ->
        res.status 500
        error
      .done (result) ->
        console.log 'giving response', result
        res.json result
  else
    require('../actions/torrent_checker').checkNow()
      .fail (error) ->
        res.status 500
        error
      .done (result) ->
        console.log 'giving response', result
        res.json result
  
module.exports = app