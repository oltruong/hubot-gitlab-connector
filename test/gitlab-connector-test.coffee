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
        setTimeout(resolve, 1000);
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds with pipeline info', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab pipeline trigger 123 dev']
      ['hubot', '@alice Pipeline 7 created on branch develop of project toto. See http://example.com/toto/toto-client/pipelines/7']
    ]

describe 'gitlab version', ->
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
        setTimeout(resolve, 1000);
      )

  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab version', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab version']
      ['hubot', '@alice gitlab version is 8.13.0-pre, revision 4e963fe']
    ]

describe 'gitlab branches', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect
    nock('http://gitlab.com')
      .get('/api/v4/projects/123/repository/branches')
      .reply 200, '[{"name":"develop", "commit":{"short_id":"c0e0062e","title":"my commit","created_at":"2017-12-13T10:03:59.000+01:00","author_name":"John Doe"} },{"name":"master", "commit":{"short_id":"c0e0062f","title":"my first commit","created_at":"2017-12-01T10:03:59.000+01:00","author_name":"Henry Doe"}}]'
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab branches 123')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000);
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab branches', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab branches 123']
      ['hubot',
        '@alice 2 branches found\ndevelop\n  last commit \"c0e0062e\", title \"my commit\" by \"John Doe\" created at \"2017-12-13T10:03:59.000+01:00\"\n\nmaster\n  last commit \"c0e0062f\", title \"my first commit\" by \"Henry Doe\" created at \"2017-12-01T10:03:59.000+01:00\"']
    ]

describe 'gitlab project', ->
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
        setTimeout(resolve, 1000);
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab projects', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab projects toto']
      ['hubot',
        '@alice 2 projects found matching name toto\ntoto, id:123\nWonderful project\n  web url: http://example.com/toto/toto-client, group: totogroup, last activity: 2017-12-07T13:48:40.953Z\n\ntoto2, id:246\nWonderful project returns\n  web url: http://example.com/toto/toto-client2, group: totogroup, last activity: 2017-12-09T13:48:40.953Z']
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
        ['hubot',
          '@bob Here are all the available commands:\ngitlab projects searchName - shows the projects whose name contains searchName\ngitlab pipeline trigger projectId branchName - triggers a pipeline on a branch matching branchName for the project with Id projectId\ngitlab branches projectId - shows the branches for the project with Id projectId\ngitlab version - returns version\ngitlab help - displays all available commands']
      ]
  it 'responds to an unkown command', ->
    @room.user.say('averell', '@hubot gitlab whatever').then =>
      expect(@room.messages).to.eql [
        ['averell', '@hubot gitlab whatever']
        ['hubot',
          "@averell Sorry, I did not understand command 'whatever'. Here are all the available commands:\ngitlab projects searchName - shows the projects whose name contains searchName\ngitlab pipeline trigger projectId branchName - triggers a pipeline on a branch matching branchName for the project with Id projectId\ngitlab branches projectId - shows the branches for the project with Id projectId\ngitlab version - returns version\ngitlab help - displays all available commands"]
      ]
