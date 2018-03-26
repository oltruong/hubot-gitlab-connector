Helper = require('hubot-test-helper')
chai = require 'chai'
expect = chai.expect
nock = require('nock')
co = require('co')

helper = new Helper('../src/gitlab-connector.coffee')


describe 'merge requests', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect
    nock('http://gitlab.com')
      .get('/api/v4/projects/123/merge_requests')
      .reply 200, '[{"iid":68, "title":"Merge 1", "upvotes":0,"downvotes":1,"target_branch":"acceptance","source_branch":"dev", "updated_at":"2018-01-04T16:04:54.598Z", "author":{"name":"Bob"},"web_url":"http://gitlab.com/toto/merge_requests/68", "state": "opened"},{"iid":78, "title":"Merge production","target_branch":"production","source_branch":"acceptance", "upvotes":3,"downvotes":0, "updated_at":"2018-01-05T16:04:54.598Z", "author":{"name":"Jack"},"web_url":"http://gitlab.com/toto/merge_requests/78", "state": "merged"}]'
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab merge requests 123')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab merge requests', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab merge requests 123']
      ['hubot',
        '@alice 2 merge requests found\n- id: 68, Merge 1, from dev to acceptance\n  state: OPENED, updated at \"2018-01-04T16:04:54.598Z\", author: Bob\n  upvotes: 0, downvotes: 1\n  http://gitlab.com/toto/merge_requests/68\n\n- id: 78, Merge production, from acceptance to production\n  state: MERGED, updated at "2018-01-05T16:04:54.598Z", author: Jack\n  upvotes: 3, downvotes: 0\n  http://gitlab.com/toto/merge_requests/78']
    ]


describe 'merge requests with filter', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect
    nock('http://gitlab.com')
      .get('/api/v4/projects/123/merge_requests?state=closed')
      .reply 200, '[{"iid":68, "title":"Merge 1", "upvotes":0,"downvotes":1,"target_branch":"acceptance","source_branch":"dev", "updated_at":"2018-01-04T16:04:54.598Z", "author":{"name":"Bob"},"web_url":"http://gitlab.com/toto/merge_requests/68", "state": "closed"},{"iid":78, "title":"Merge production","target_branch":"production","source_branch":"acceptance", "upvotes":3,"downvotes":0, "updated_at":"2018-01-05T16:04:54.598Z", "author":{"name":"Jack"},"web_url":"http://gitlab.com/toto/merge_requests/78", "state": "closed"}]'
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab merge requests 123 state=closed')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab merge requests', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab merge requests 123 state=closed']
      ['hubot',
        '@alice 2 merge requests found\n- id: 68, Merge 1, from dev to acceptance\n  state: CLOSED, updated at \"2018-01-04T16:04:54.598Z\", author: Bob\n  upvotes: 0, downvotes: 1\n  http://gitlab.com/toto/merge_requests/68\n\n- id: 78, Merge production, from acceptance to production\n  state: CLOSED, updated at "2018-01-05T16:04:54.598Z", author: Jack\n  upvotes: 3, downvotes: 0\n  http://gitlab.com/toto/merge_requests/78']
    ]


describe 'merge requests: accept with id', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect
    nock('http://gitlab.com')
      .put('/api/v4/projects/123/merge_requests/68/merge')
      .reply 200, '{"iid":68, "title":"Merge 1", "upvotes":0,"downvotes":1,"target_branch":"acceptance","source_branch":"dev", "updated_at":"2018-01-04T16:04:54.598Z", "author":{"name":"Bob"},"web_url":"http://gitlab.com/toto/merge_requests/68", "state": "merged"}'
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab merge requests 123 accept 68')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab merge requests', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab merge requests 123 accept 68']
      ['hubot',
        '@alice merge request 68 is now merged.\nSee http://gitlab.com/toto/merge_requests/68']
    ]


describe 'merge requests: accept with branches', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect

    nock('http://gitlab.com')
    .get('/api/v4/projects/123/merge_requests?state=opened')
    .reply 200, '[{"iid":67, "title":"Merge 1", "upvotes":0,"downvotes":1,"target_branch":"c","source_branch":"a", "updated_at":"2018-01-04T16:04:54.598Z", "author":{"name":"Bob"},"web_url":"http://gitlab.com/toto/merge_requests/68", "state": "opened"},{"iid":68, "title":"Merge 1", "upvotes":0,"downvotes":1,"target_branch":"b","source_branch":"a", "updated_at":"2018-01-04T16:04:54.598Z", "author":{"name":"Bob"},"web_url":"http://gitlab.com/toto/merge_requests/68", "state": "opened"}]'

    nock('http://gitlab.com')
      .put('/api/v4/projects/123/merge_requests/68/merge')
      .reply 200, '{"iid":68, "title":"Merge 1", "upvotes":0,"downvotes":1,"target_branch":"b","source_branch":"a", "updated_at":"2018-01-04T16:04:54.598Z", "author":{"name":"Bob"},"web_url":"http://gitlab.com/toto/merge_requests/68", "state": "merged"}'
    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab merge requests 123 accept from a to b')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab merge requests', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab merge requests 123 accept from a to b']
      ['hubot',
        '@alice merge request 68 is now merged.\nSee http://gitlab.com/toto/merge_requests/68']
    ]

describe 'merge requests: accept with no branches', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect

    nock('http://gitlab.com')
    .get('/api/v4/projects/123/merge_requests?state=opened')
    .reply 200, '[{"iid":67, "title":"Merge 1", "upvotes":0,"downvotes":1,"target_branch":"c","source_branch":"a", "updated_at":"2018-01-04T16:04:54.598Z", "author":{"name":"Bob"},"web_url":"http://gitlab.com/toto/merge_requests/68", "state": "opened"}]'

    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab merge requests 123 accept from a to b')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab merge requests', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab merge requests 123 accept from a to b']
      ['hubot',
        '@alice Sorry, no merge request opened found from a to b']
    ]

describe 'merge requests: accept with multiple branches', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect

    nock('http://gitlab.com')
    .get('/api/v4/projects/123/merge_requests?state=opened')
    .reply 200, '[{"iid":67, "title":"Merge 1", "upvotes":0,"downvotes":1,"target_branch":"b","source_branch":"a", "updated_at":"2018-01-04T16:04:54.598Z", "author":{"name":"Bob"},"web_url":"http://gitlab.com/toto/merge_requests/68", "state": "opened"},{"iid":68, "title":"Merge 1", "upvotes":0,"downvotes":1,"target_branch":"b","source_branch":"a", "updated_at":"2018-01-04T16:04:54.598Z", "author":{"name":"Bob"},"web_url":"http://gitlab.com/toto/merge_requests/68", "state": "opened"}]'

    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab merge requests 123 accept from a to b')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab merge requests', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab merge requests 123 accept from a to b']
      ['hubot',
        '@alice Sorry, 2 merge requests opened from a to b. Please be more specific. Here are the merge requests\n- id: 67, Merge 1, from a to b\n  state: OPENED, updated at \"2018-01-04T16:04:54.598Z\", author: Bob\n  upvotes: 0, downvotes: 1\n  http://gitlab.com/toto/merge_requests/68,- id: 68, Merge 1, from a to b\n  state: OPENED, updated at \"2018-01-04T16:04:54.598Z\", author: Bob\n  upvotes: 0, downvotes: 1\n  http://gitlab.com/toto/merge_requests/68']
    ]


describe 'merge requests: accept with multiple branches', ->
  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect

    nock('http://gitlab.com')
    .get('/api/v4/projects/123/merge_requests?state=opened')
    .reply 200, '[{"iid":67, "title":"Merge 1", "upvotes":0,"downvotes":1,"target_branch":"b","source_branch":"a", "updated_at":"2018-01-04T16:04:54.598Z", "author":{"name":"Bob"},"web_url":"http://gitlab.com/toto/merge_requests/68", "state": "opened"},{"iid":68, "title":"Merge 1", "upvotes":0,"downvotes":1,"target_branch":"b","source_branch":"a", "updated_at":"2018-01-04T16:04:54.598Z", "author":{"name":"Bob"},"web_url":"http://gitlab.com/toto/merge_requests/68", "state": "opened"}]'

    process.env.HUBOT_GITLAB_URL = "http://gitlab.com"
    process.env.HUBOT_GITLAB_TOKEN = "secretToken"
    co =>
      @room.user.say('alice', '@hubot gitlab merge requests 123 accept from a to b')
      new Promise((resolve, reject) ->
        setTimeout(resolve, 1000)
      )
  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to gitlab merge requests', ->
    expect(@room.messages).to.eql [
      ['alice', '@hubot gitlab merge requests 123 accept from a to b']
      ['hubot',
        '@alice Sorry, 2 merge requests opened from a to b. Please be more specific. Here are the merge requests\n- id: 67, Merge 1, from a to b\n  state: OPENED, updated at \"2018-01-04T16:04:54.598Z\", author: Bob\n  upvotes: 0, downvotes: 1\n  http://gitlab.com/toto/merge_requests/68,- id: 68, Merge 1, from a to b\n  state: OPENED, updated at \"2018-01-04T16:04:54.598Z\", author: Bob\n  upvotes: 0, downvotes: 1\n  http://gitlab.com/toto/merge_requests/68']
    ]
