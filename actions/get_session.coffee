async = require 'async'
api   = require './api'

module.exports = (callback) ->
  async.waterfall [
    (callback) -> api 'session-get', {}, callback
    (result, callback) ->
      if result.result is 'success'
        callback null, result.arguments
      else
        callback result
  ], callback