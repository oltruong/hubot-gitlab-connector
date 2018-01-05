Helper = require('hubot-test-helper')
chai = require 'chai'
expect = chai.expect
nock = require('nock')
co = require('co')

helper = new Helper('../src/gitlab-connector.coffee')

describe 'gitlab pipeline trigger', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect
    nock('http://gitlab.com')
      .get('/api/v4/projects/123/triggers')
      .reply 200, '[{"id":35,"token":"647a839ad36a23273f1c9056628735"}]'

    nock('http://gitlab.com')
      .get('/api/v4/projects/123')
      .reply 200, '{"id":123,"name":"toto", "web_url": "http://example.com/toto/toto-client"}'

    nock('http://gitlab.com')
      .get('/api/v4/projects/123/repository/branches')
      .reply 200, '[{"name":"develop"},{"name":"master"}]'

    nock('http://gitlab.com')
      .post('/api/v4/projects/123/trigger/pipeline')
      .reply 201, '{"id":7,"status":"pending"}'

    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab pipeline trigger 123 dev')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds with pipeline info', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab pipeline trigger 123 dev']
      ['hubot',
        '@alice Pipeline 7 created on branch develop of project toto. See http://example.com/toto/toto-client/pipelines/7']
    ]

