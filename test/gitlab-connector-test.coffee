Helper = require('hubot-test-helper')
chai = require 'chai'
expect = chai.expect
nock = require('nock')
co = require('co')

helper = new Helper('../src/gitlab-connector.coffee')

describe 'gitlab-connector commands with http connection', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect
    nock('http://gitlab.com')
      .get('/hello')
      .reply 200, 'hello'
    #      .get('/version')
    #      .reply 200, '{"version": "8.13.0-pre","revision": "4e963fe"}'
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab project')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000);
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab project', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab project']
      ['hubot', '@alice hello']
    ]

describe 'gitlab-connector commands without http connection', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  it 'responds to help', ->
    @room.user.say('bob', '@hubot gitlab help').then =>
      expect(@room.messages).to.eql [
        ['bob', '@hubot gitlab help']
        ['hubot', '@bob help\'s on the way']
      ]

  it 'responds to an unkown command', ->
    @room.user.say('averell', '@hubot gitlab whatever').then =>
      expect(@room.messages).to.eql [
        ['averell', '@hubot gitlab whatever']
        ['hubot', '@averell Sorry I did not understand. \'gitlab help\' will provide you with all available commands']
      ]
