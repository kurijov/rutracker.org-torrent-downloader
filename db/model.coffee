Q       = require 'q'
db      = require './index'
_       = require 'lodash'

class Model
  @persistConstructor: ->
    @persistModel

  constructor: (data) ->
    if data instanceof @constructor.persistConstructor()
      instance = data
    else
      instance = new (@constructor.persistConstructor()) data

    proxyMethods = ['save', 'delete', 'update']
    _.each proxyMethods, (method) ->
      _deattachedMethod = instance[method]
      instance["$#{method}"] = (params...) ->

        db.then (connection) ->
          promise = Q.denodeify (callback) -> 
            paramsToCall = [].concat([connection]).concat(params).concat([callback])
            _deattachedMethod.apply instance, paramsToCall

          promise()

    return instance

  @getById: (id) ->
    db.then (connection) =>
      Q.ninvoke(@persistConstructor(), 'getById', connection, id)
        .then (item) =>
          if item
            new @ item
          else
            throw new Error "Not found #{id}"

  @query: ->
    new Query @
    # where: -> 
    # all: =>
    #   db
    #     .then (connection) =>
    #       Q.ninvoke (@persistConstructor()).using(connection), 'all'
    #     .then (items) =>
    #       (new (@) item for item in items)

class Query 
  constructor: (@modelConstructor) -> 
    @query = db
      .then (connection) =>
        @modelConstructor.persistConstructor().using connection

  where: (params...) ->
    @query.then (query) ->
      query.apply query, params
    @

  all: ->
    @query
      .then (query) ->
        console.log 'got then'
        Q.ninvoke query, 'all'
      .then (items) =>
        console.log 'got items'
        (new (@modelConstructor) item for item in items)
      .fail (error) =>
        console.log "Error at query: #{@modelConstructor.name}", error
        throw error

module.exports = Model