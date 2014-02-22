expect = require('chai').expect
sinon  = require 'sinon'
Q      = require 'q'
_      = require 'lodash'

transmission =
  stub: (transmission) ->
    @_stubs = []
    @_stubs.push get_session = sinon.stub transmission, 'get_session'

    get_session.returns Q({})

    @_stubs.push add_torrent = sinon.stub transmission, 'add_torrent'

    add_torrent.returns Q({})

  unstub: ->
    _.each @_stubs, (stub) ->
      stub.restore()

tracker =
  stub: (tracker) ->
    @_t_stubs = []
    @_t_stubs.push download_torrent = sinon.stub tracker, 'download_torrent'

    download_torrent.returns Q()

    @_t_stubs.push get_torrent_title = sinon.stub tracker, 'get_torrent_title'
    get_torrent_title.returns Q()

  unstub: ->
    _.each @_t_stubs, (stub) ->
      stub.restore()


describe 'manager', ->
  before ->
    @valid_torrent_url = "http://rutracker.org/forum/viewtopic.php?t=4541800"

  before ->
    @manager = (require('../../manager'))

  before ->
    tracker.stub @manager.tracker
    transmission.stub @manager.transmission

  after ->
    tracker.unstub()
    transmission.unstub()


  describe 'add torrent', ->

    it 'should be ok', ->

      expect(@manager.add_torrent(@valid_torrent_url)).to.be.fulfilled

