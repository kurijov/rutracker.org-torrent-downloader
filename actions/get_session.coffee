async = require 'async'
api   = require './api'

module.exports = () ->
  api('session-get', {})
    .then( (result) ->
      if result.result is 'success'
        result.arguments
      else
        throw new Error result
    )