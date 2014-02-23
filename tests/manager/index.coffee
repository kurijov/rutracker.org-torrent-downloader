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
    add_torrent.returns Q({id: 1, hashString: 'blabla'})

    @_stubs.push torrent_get = sinon.stub transmission, 'torrent_get'
    torrent_get.returns Q([{id: 1, hashString: 'blabla'}])

    @_stubs.push torrent_remove = sinon.stub transmission, 'torrent_remove'
    torrent_remove.returns Q()

  unstub: ->
    _.each @_stubs, (stub) ->
      stub.restore()

tracker =
  stub: (tracker, title = yes) ->
    @_t_stubs = []
    @_t_stubs.push download_torrent = sinon.stub tracker, 'download_torrent'

    download_torrent.returns Q()

    if title
      @_t_stubs.push get_torrent_title = sinon.stub tracker, 'get_torrent_title'
      get_torrent_title.returns Q('title1')

  unstub: ->
    _.each @_t_stubs, (stub) ->
      stub.restore()


describe 'manager', ->
  before ->
    @valid_torrent_url = "http://rutracker.org/forum/viewtopic.php?t=4541800"

  before ->
    @manager = (require('../../manager'))

  before ->
    tracker.stub @manager.tracker, no
    transmission.stub @manager.transmission

  after ->
    tracker.unstub()
    transmission.unstub()


  describe 'add torrent', ->

    before ->
      @get_torrent_title = sinon.stub @manager.tracker, 'get_torrent_title'
      @get_torrent_title.returns Q('title1')

      @_result = @manager.add_torrent(@valid_torrent_url)

    after ->
      @get_torrent_title.restore()

    it 'should be ok', ->
      expect(@_result).to.be.fulfilled

    it 'should be a torrent', ->
      expect(@_result).eventually.have.property 'id'

  describe 'check torrent', ->

    describe 'if title didnt change', ->
      before ->
        @get_torrent_title = sinon.stub @manager.tracker, 'get_torrent_title'
        @get_torrent_title.returns Q('title1')

      after ->
        @get_torrent_title.restore()

      before ->
        @_reload_spy = sinon.spy @manager, 'reload_torrent'

        @_result = @manager.check_torrent 1

      after ->
        @_reload_spy.restore()

      it 'should be ok', ->
        expect(@_result).to.be.fulfilled

      it 'reload should not be called', ->
        expect(@_reload_spy.called).to.be.not.ok

      it 'torrent should not be in job', ->
        @_result.then (item) ->
          expect(item.in_job).to.eql 0

    describe 'when title changed', ->

      before ->
        @get_torrent_title = sinon.stub @manager.tracker, 'get_torrent_title'
        @get_torrent_title.returns Q('title2')

      after ->
        @get_torrent_title.restore()

      before ->
        @_reload_spy = sinon.spy @manager, 'reload_torrent'

      after ->
        @_reload_spy.restore()

      before ->
        @_result = @manager.check_torrent 1

      it 'reload should be called', ->
        expect(@_reload_spy.called).to.be.ok

      it 'should be ok', ->
        expect(@_result).to.be.fulfilled

      it 'torrent should not be in job', ->
        @_result.then (item) ->
          expect(item.in_job).to.eql 0








