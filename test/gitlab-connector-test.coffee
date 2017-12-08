Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

helper = new Helper('../src/gitlab-connector.coffee')

describe 'gitlab-connector', ->
  beforeEach ->
    @room = helper.createRoom()
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com/"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"

  afterEach ->
    @room.destroy()

  it 'responds to gitlab project', ->
    @room.user.say('alice', '@hubot gitlab project').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot gitlab project']
        ['hubot', '@alice hello!']
      ]

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
