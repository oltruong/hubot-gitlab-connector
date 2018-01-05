Helper = require('hubot-test-helper')
chai = require 'chai'
expect = chai.expect
nock = require('nock')
co = require('co')

helper = new Helper('../src/gitlab-connector.coffee')


describe 'gitlab projects', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect
    nock('http://gitlab.com')
      .get('/api/v4/projects')
      .reply 200, '[{"id":123,"name":"toto", "description":"Wonderful project", "web_url": "http://example.com/toto/toto-client", "namespace":{"name":"totogroup"}, "last_activity_at": "2017-12-07T13:48:40.953Z"},{"id":246,"name":"toto2", "description":"Wonderful project returns", "web_url": "http://example.com/toto/toto-client2", "namespace":{"name":"totogroup"}, "last_activity_at": "2017-12-09T13:48:40.953Z"}]'
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab projects')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000);
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab projects', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab projects']
      ['hubot',
        '@alice 2 projects found.\n- toto, id:123\n  Wonderful project\n  web url: http://example.com/toto/toto-client, group: totogroup, last activity: 2017-12-07T13:48:40.953Z\n\n\n- toto2, id:246\n  Wonderful project returns\n  web url: http://example.com/toto/toto-client2, group: totogroup, last activity: 2017-12-09T13:48:40.953Z']
    ]

describe 'gitlab project search', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect
    nock('http://gitlab.com')
      .get('/api/v4/projects?search=toto')
      .reply 200, '[{"id":123,"name":"toto", "description":"Wonderful project", "web_url": "http://example.com/toto/toto-client", "namespace":{"name":"totogroup"}, "last_activity_at": "2017-12-07T13:48:40.953Z"},{"id":246,"name":"toto2", "description":"Wonderful project returns", "web_url": "http://example.com/toto/toto-client2", "namespace":{"name":"totogroup"}, "last_activity_at": "2017-12-09T13:48:40.953Z"}]'
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab projects toto')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab projects search', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab projects toto']
      ['hubot',
        '@alice 2 projects found.\n- toto, id:123\n  Wonderful project\n  web url: http://example.com/toto/toto-client, group: totogroup, last activity: 2017-12-07T13:48:40.953Z\n\n\n- toto2, id:246\n  Wonderful project returns\n  web url: http://example.com/toto/toto-client2, group: totogroup, last activity: 2017-12-09T13:48:40.953Z']
    ]
