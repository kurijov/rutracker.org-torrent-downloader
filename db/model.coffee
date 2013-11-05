Q       = require 'q'
db      = require './index'
_       = require 'lodash'

class Model
  @persistConstructor: ->
    @persistModel

  _transfer_getters_setters: (keys) ->

  constructor: (data) ->
    if data instanceof @constructor.persistConstructor()
      instance = data
    else
      instance = new (@constructor.persistConstructor()) data

    # keys = _.keys @constructor.persistConstructor().columns

    # _.each keys, (key) =>
    #   @__defineGetter__ key, ->
    #     instance[key]

    #   @__defineSetter__ key, (value) ->
    #     instance[key] = value



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

class Query 
  constructor: (@modelConstructor) -> 
    @query = db
      .then (connection) =>
        @modelConstructor.persistConstructor().using connection

  where: (params...) ->
    @query.then (query) ->
      query.where.apply query, params
    @

  first: ->
    @query
      .then (query) ->
        Q.ninvoke query, 'first'
      .then (item) =>
        if item
          new (@modelConstructor) item
        else
          return null
      .fail (error) =>
        console.log "Error at query: #{@modelConstructor.name}", error
        throw error

  all: ->
    @query
      .then (query) ->
        Q.ninvoke query, 'all'
      .then (items) =>
        (new (@modelConstructor) item for item in items)
      .fail (error) =>
        console.log "Error at query: #{@modelConstructor.name}", error
        throw error

module.exports = Model