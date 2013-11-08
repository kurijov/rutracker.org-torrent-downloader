request = require 'request'
config  = require '../config'
Q       = require 'q'

Config  = require '../db/config'

jar     = request.jar()

apiToken          = null
wrongTokenCounter = 0

requestQ = (requestData) ->
  deferred = Q.defer()

  request requestData, (error, response, result) ->
    return deferred.reject new Error error if error

    deferred.resolve {response, result}


  deferred.promise


apiCall = (method, params) ->
  Config.get('transmission')
    .then (config) ->
      host = config.host + "/transmission/rpc"

      data = 
        method    : method
        arguments : params or {}

      headers = { }

      if apiToken
        headers["X-Transmission-Session-Id"] = apiToken
      
      requestData = 
        method  : 'POST'
        body    : JSON.stringify(data)
        uri     : host
        headers : headers
        jar     : jar

      requestQ(requestData)
    .then ({result, response}) ->
      if response.statusCode is 409 # wrong token
        wrongTokenCounter++
        if wrongTokenCounter > 10
          console.log 'something wrong with server, it doesnt accept our headers'
          process.exit()
        apiToken = response.headers['x-transmission-session-id']
        console.log 'new token', apiToken
        apiCall method, params
      else
        wrongTokenCounter = 0
        json = JSON.parse result


module.exports = apiCall