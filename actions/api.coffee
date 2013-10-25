request = require 'request'
config = require '../config'

jar = request.jar()

# X-Transmission-Session-Id

apiToken = null
wrongTokenCounter = 0

apiCall = (method, params, callback) ->
  host = config.transmission.host + "/transmission/rpc"

  data = 
    method: method
    arguments: params or {}

  headers = {
    # "X-Requested-With":"XMLHttpRequest"
    # "User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.110 Safari/537.36"
  }

  if apiToken
    headers["X-Transmission-Session-Id"] = apiToken
  
  requestData = 
    method  : 'POST'
    body    : JSON.stringify(data)
    uri     : host
    headers : headers
    jar     : jar
  # console.log 'making request', requestData

  request requestData, (error, response, result) ->
    return callback error if error
    if response.statusCode is 409 # wrong token
      wrongTokenCounter++
      if wrongTokenCounter > 10
        console.log 'something wrong with server, it doesnt accept our headers'
        process.exit()
      apiToken = response.headers['x-transmission-session-id']
      console.log 'new token', apiToken
      apiCall method, params, callback
    else
      wrongTokenCounter = 0
      json = JSON.parse result
      callback null, json

module.exports = apiCall