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

  describe "callable", ->
    before ->
      @apiStub      = sinon.stub @transmission, '_api'
      @apiStub.returns Q({result: 'success', arguments: {}})

    after ->
      @apiStub.restore()

    it 'torrent_get', ->
      expect(@transmission.torrent_get()).to.be.fulfilled

    it 'torrent_remove', ->
      expect(@transmission.torrent_remove()).to.be.fulfilled

  describe 'add_torrent', ->
    before ->
      @apiStub      = sinon.stub @transmission, '_api'
      @apiStub.returns Q({result: 'success', arguments: {}})

      fs = require 'fs'

      @fsReadFileSync = sinon.stub fs, 'readFileSync'
      @fsReadFileSync.returns new Buffer ''

    after ->
      @apiStub.restore()

    it 'should be ok', ->
      expect(@transmission.add_torrent()).to.be.fulfilled

