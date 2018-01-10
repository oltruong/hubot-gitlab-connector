Helper = require('hubot-test-helper')
chai = require 'chai'
expect = chai.expect
nock = require('nock')
co = require('co')

helper = new Helper('../src/gitlab-connector.coffee')

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
          '@bob Here are all the available commands:\ngitlab branches projectId - shows the branches for the project whose id is projectId\ngitlab projects searchName - shows the projects whose name contains searchName (optional)\ngitlab merge request projectId filter - shows the merge requests for the project whose id is projectId with filter(optional, e.g. state=opened)\ngitlab merge request projectId accept merge_iid - accepts the merge request iid for the project whose id is projectId\ngitlab pipeline trigger projectId branchName - triggers a pipeline on a branch matching branchName for the project  whose id is projectId\ngitlab version - returns version\ngitlab help - displays all available commands']
      ]
  it 'responds to an unkown command', ->
    @room.user.say('averell', '@hubot gitlab whatever').then =>
      expect(@room.messages).to.eql [
        ['averell', '@hubot gitlab whatever']
        ['hubot',
          "@averell Sorry, I did not understand command 'whatever'. Here are all the available commands:\ngitlab branches projectId - shows the branches for the project whose id is projectId\ngitlab projects searchName - shows the projects whose name contains searchName (optional)\ngitlab merge request projectId filter - shows the merge requests for the project whose id is projectId with filter(optional, e.g. state=opened)\ngitlab merge request projectId accept merge_iid - accepts the merge request iid for the project whose id is projectId\ngitlab pipeline trigger projectId branchName - triggers a pipeline on a branch matching branchName for the project  whose id is projectId\ngitlab version - returns version\ngitlab help - displays all available commands"]
      ]
