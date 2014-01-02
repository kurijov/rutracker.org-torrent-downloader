expect = require('chai').expect
sinon  = require 'sinon'
Q      = require 'q'

describe "transmission", ->
  before ->
    @transmission = new (require('../../downloaders/transmission'))
    

  describe "get_session if api is ok", ->
    before ->
      @apiStub      = sinon.stub @transmission, '_api'
      @apiStub.returns Q({result: 'success', arguments: {}})

    after ->
      @apiStub.restore()

    it 'should be good', ->
      expect(@transmission.get_session()).to.be.fulfilled

  describe 'get_session if api is bad', ->
    before ->
      @apiStub      = sinon.stub @transmission, '_api'
      @apiStub.returns Q({})

    after ->
      @apiStub.restore()

    it 'should throw an error', ->
      expect(@transmission.get_session()).to.be.rejected

  describe "add_torrent", ->