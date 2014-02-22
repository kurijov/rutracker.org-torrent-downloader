expect = require('chai').expect
sinon  = require 'sinon'
Q      = require 'q'

describe "tracker", ->
  before ->
    @tracker = new (require('../../trackers/rutracker'))

  describe 'config', ->

    it 'ok', ->
      expect(@tracker.getConfig()).to.be.fulfilled

  describe "auth", ->

    describe 'without', ->

      describe "login", ->
        before ->
          @getConfigStub = sinon.stub @tracker, 'getConfig'
          @getConfigStub.returns Q({password: "hello"})

        after ->
          @getConfigStub.restore()

        it 'fail', ->
          expect(@tracker.authorize()).to.be.rejected

      describe "pass", ->

        before ->
          @getConfigStub = sinon.stub @tracker, 'getConfig'
          @getConfigStub.returns Q({login: "superpass"})

        after ->
          @getConfigStub.restore()

        it 'fail', ->
          expect(@tracker.authorize()).to.be.rejected

    describe 'with login/pass', ->

      before ->
        @getConfigStub = sinon.stub @tracker, 'getConfig'
        @getConfigStub.returns Q({login: 'superman', password: "hello"})

      describe "on failed auth", ->
        before ->
          @post_stub = sinon.stub @tracker, '_post_auth_data'
          @post_stub.returns Q('action="http://login.rutracker.org/forum/login.php"')

        after ->
          @post_stub.restore()

        it "auth should fail", ->
          expect(@tracker.authorize()).to.be.rejected

        it 'authorized property should be false', ->
          expect(@tracker.authorized).to.be.not.ok

      describe "on success auth", ->
        before ->
          @post_stub = sinon.stub @tracker, '_post_auth_data'
          @post_stub.returns Q('blabla html')

        after ->
          @post_stub.restore()

        it "auth should be ok", ->
          expect(@tracker.authorize()).to.be.fulfilled

        it 'authorized property should be true', ->
          expect(@tracker.authorized).to.be.ok


describe "tracker", ->
  before ->
    @tracker = new (require('../../trackers/rutracker'))

  #   @getConfigStub = sinon.stub @tracker, 'getConfig'
  #   @getConfigStub.returns Q({login: 'super', password: "man"})

  # after ->
  #   @getConfigStub.restore()

  describe "download", ->

    describe "with invalid url", ->

      it 'should fail', ->

        expect(@tracker.download_torrent("bla")).to.be.rejected

    describe "with failed download", ->
      before ->
        @authorizeStub = sinon.stub @tracker, 'authorize'
        @authorizeStub.returns Q()

        @downloadStub = sinon.stub @tracker, '_download_torrent_file'
        @downloadStub.returns Q.reject()

        @checkTorrentSpy = sinon.stub @tracker, 'check_torrent_file'

      after ->
        @downloadStub.restore()
        @checkTorrentSpy.restore()
        @authorizeStub.restore()

      it 'should fail', ->
        expect(@tracker.download_torrent("http://rutracker.org/forum/viewtopic.php?t=4541800")).to.be.rejected

      it 'check_torrent_file should not be called', ->
        expect(@checkTorrentSpy.called).to.be.not.ok

    describe "with valid url", ->
      before ->
        @authorizeStub = sinon.stub @tracker, 'authorize'
        @authorizeStub.returns Q()

        @downloadStub = sinon.stub @tracker, '_download_torrent_file'
        @downloadStub.returns Q('some file path')

        @checkTorrentSpy = sinon.spy @tracker, 'check_torrent_file'

        @_checkTorrentStub = sinon.stub @tracker, '_check_torrent_file'
        @_checkTorrentStub.returns Q()

        @downloadResult = @tracker.download_torrent("http://rutracker.org/forum/viewtopic.php?t=4541800")

      after ->
        @authorizeStub.restore()
        @downloadStub.restore()
        @_checkTorrentStub.restore()
        @checkTorrentSpy.restore()

      it 'should call _download_torrent_file', ->
        expect(@downloadStub.called).to.be.ok

      it 'should call check_torrent_file', ->
        expect(@checkTorrentSpy.called).to.be.ok

      it 'should call _check_torrent_file', ->
        expect(@_checkTorrentStub.called).to.be.ok

      it 'must return file path', ->
        expect(@downloadResult).to.be.fulfilled
        expect(@downloadResult).to.eventually.eql 'some file path'

    describe "with corrupted file", ->

      before ->
        @authorizeStub = sinon.stub @tracker, 'authorize'
        @authorizeStub.returns Q()

        @downloadStub = sinon.stub @tracker, '_download_torrent_file'
        @downloadStub.returns Q('some file path')

        @_checkTorrentStub = sinon.stub @tracker, '_check_torrent_file'
        @_checkTorrentStub.returns Q.reject('wrong data')

      after ->
        @authorizeStub.restore()
        @downloadStub.restore()
        @_checkTorrentStub.restore()
        @checkTorrentSpy.restore()

      it 'should fail', ->
        result = @tracker.download_torrent("http://rutracker.org/forum/viewtopic.php?t=4541800")
        expect(result).to.be.rejected
        result.fail (e) =>
          expect(e).to.eql @errors.TRACKER.BAD_FILE()




