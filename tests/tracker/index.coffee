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

  describe "download", ->

    describe "with invalid url", ->

      it 'should fail', ->

        expect(@tracker.download_torrent("bla")).to.be.rejected


