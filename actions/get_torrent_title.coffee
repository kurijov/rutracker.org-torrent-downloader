async   = require 'async'
request = require 'request'
Q       = require 'q'
jsdom   = require("jsdom")

module.exports = Q.denodeify (url, callback) ->
  async.waterfall [
    (callback) -> 
      requestData =
        url      : url
        encoding : null
        method   : "GET"

      request requestData, callback
    (response, result, callback) ->
      # console.log response.statusCode, "statusCode"
      if response.statusCode is 200
        iconv = require('iconv').Iconv 'windows-1251', 'utf-8'
        callback null, iconv.convert(result).toString()
      else
        callback "Error happened: " + response.statusCode
    (html, callback) ->
      jsdom.env html, ["http://code.jquery.com/jquery.js"], callback
    (window, callback) ->
      callback null, window.$("h1.maintitle a").text()

  ], callback
