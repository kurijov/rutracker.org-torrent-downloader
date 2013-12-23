_    = require('lodash')
util = require 'util'
fs   = require('fs')

TError = require('./terror')

errorsFolder = __dirname + '/list'

listOfModules = _.filter fs.readdirSync(errorsFolder), (moduleName) ->
  [baseName, ext] = moduleName.split('.')
  if ext in ['js', 'coffee']
    yes
  else
    no

# listOfModules = [
#   'common'
#   'stripe'
#   'user'
#   'votable'
#   'connect'
#   'blot'
#   'queue'
#   'topic'
#   'pixlnet'
#   'photo'
#   'g_change_log'
#   'comment'
# ]

class ErrorManager
  constructor: ->
    @_registeredCodes = []
    @_load()

  _registerCode: (code) ->
    throw new Error "#{code} already registered at the code base" if code in @_registeredCodes

    @_registeredCodes.push code

  _load: ->
    _.each listOfModules, (moduleName) =>
      @_attach moduleName, require(errorsFolder + "/#{moduleName}")

  _attach: (namespace, errorsList) ->
    namespace = namespace.toUpperCase()

    unless @[namespace]
      @[namespace] = {}

    listOfCodeNames = _.without _.keys(errorsList), '_space'

    _.each listOfCodeNames, (codeName) =>
      @[namespace][codeName] = @_create_error_proxy_fn(codeName, errorsList)

  _create_error_proxy_fn: (codeName, errorsList) ->
    [numberCode, others...] = errorsList[codeName].split(' ')

    numberCode = parseInt errorsList._space + numberCode
    message    = others.join ' '

    @_registerCode numberCode

    createErrorFn = (params...) ->
      formattedMessage = message
      unless _.isObject(params[0])
        formattedMessage = util.format.apply(util, [message].concat(params))

      errorToReturn = new TError formattedMessage, numberCode
      if _.isObject(params[0])
        _.extend errorToReturn, params[0]

      errorToReturn

    createErrorFn.is = (error) -> error?.code is numberCode
    createErrorFn.isnt = (error) -> !createErrorFn.is(error)

    createErrorFn


module.exports = new ErrorManager