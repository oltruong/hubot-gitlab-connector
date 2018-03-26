Helper = require('hubot-test-helper')
chai = require 'chai'
expect = chai.expect
nock = require('nock')
co = require('co')

helper = new Helper('../src/gitlab-connector.coffee')

describe 'version', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect
    nock('http://gitlab.com')
      .get('/api/v4/version')
      .reply 200, '{"version": "8.13.0-pre","revision": "4e963fe"}'
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab version')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )

  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab version', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab version']
      ['hubot', '@alice gitlab version is 8.13.0-pre, revision 4e963fe']
    ]

describe 'version KO', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect
    nock('http://gitlab.com')
      .get('/api/v4/version')
      .reply 400, 'error'
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab version')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )

  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab version', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab version']
      ['hubot', '@alice Request Failed HTTP 400 Body [error]']
    ]

describe 'version KO error', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect
    nock('http://gitlab.com')
      .get('/api/v4/version')
     .replyWithError('something awful happened');
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab version')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )

  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab version', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab version']
      ['hubot', '@alice Encountered an error :( Error: something awful happened']
    ]
