_    = require('lodash')
util = require 'util'
fs   = require('fs')

TError = require('./terror')

errorsFolder = __dirname + '/list'

listOfModules = _.chain(fs.readdirSync(errorsFolder)).filter((moduleName) ->
  [baseName, ext] = moduleName.split('.')
  if ext in ['js', 'coffee']
    yes
  else
    no
  ).map (moduleName) ->
    [baseName, ext] = moduleName.split('.')
    baseName
  .value()

class ErrorManager
  constructor: ->
    @_registeredCodes = []
    @_load()

  _registerCode: (code) ->
    throw new Error "#{code} already registered at the code base" if code in @_registeredCodes

    @_registeredCodes.push code

  _load: ->
    _.each listOfModules, (moduleName) =>
      console.log 'registering codes for ' + moduleName
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