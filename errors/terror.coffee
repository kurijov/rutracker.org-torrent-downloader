_ = require 'lodash'

class TError extends Error
  constructor: (message, code) ->
    super
    @code    = code
    @message = message

  is: (error) -> error?.code is @code
  isnt: (error) -> !@is(error)

  toJSON: ->
    _.pick @, _.keys(@)

module.exports = TError