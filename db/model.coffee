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

  @findById: (id) ->
    Q.ninvoke(@persistConstructor(), 'findById', id)
      .then (item) =>
        if item
          new @ item
        else
          throw new Error "Not found #{id}"

  @query: ->
    all: =>
      db
        .then (connection) =>
          Q.ninvoke (@persistConstructor()).using(connection), 'all'
        .then (items) =>
          (new (@) item for item in items)

module.exports = Model