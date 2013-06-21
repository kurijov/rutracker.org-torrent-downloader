config  = require './config'
async   = require 'async'
request = require 'request'

appCommand = (route, params = {}, callback) ->
  requestData =
    url    : "http://localhost:#{config.web_port}/#{route}"
    method : 'POST'
    json   : params

  async.waterfall [
    (callback) -> request requestData, callback
    (response, result, callback) -> 
      if response.statusCode isnt 200
        callback result
      else
        callback null, result
  ], callback

module.exports = appCommand