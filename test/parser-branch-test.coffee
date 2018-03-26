Helper = require('hubot-test-helper')
chai = require 'chai'
expect = chai.expect
nock = require('nock')
co = require('co')
helper = new Helper('../src/gitlab-connector.coffee')


describe 'branches', ->
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
        setTimeout(resolve, 1000)
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab branches', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab branches 123']
      ['hubot',
        '@alice 2 branches found\n- develop\n  last commit \"c0e0062e\", title \"my commit\" by \"John Doe\" created at \"2017-12-13T10:03:59.000+01:00\"\n\n- master\n  last commit \"c0e0062f\", title \"my first commit\" by \"Henry Doe\" created at \"2017-12-01T10:03:59.000+01:00\"']
    ]


describe 'branches incorrect', ->
  beforeEach ->
    @room = helper.createRoom()
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab branches 123 invalid')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab branches help', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab branches 123 invalid']
      ['hubot',
        '@alice Correct usage is gitlab branches <projectId>']
    ]

