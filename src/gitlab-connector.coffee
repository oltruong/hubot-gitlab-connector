# Description
#   A hubot script that communicates with Gitlab
#
# Configuration:
#   HUBOT_GITLAB_URL
#   HUBOT_GITLAB_TOKEN
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Olivier Truong <olivier@oltruong.com>


# /api/v4/projects?search=myproject"

module.exports = (robot) ->
  robot.respond /gitlab (.*)/, (res) ->
    url = process.env.HUBOT_GITLAB_URL
    token = process.env.HUBOT_GITLAB_TOKEN
    command = res.match[1].split " "

    gitlabClient = new GitlabClient(robot, url, token)

    switch command[0]
      when "pipeline" then createPipeline(gitlabClient, res, command)
      when "branches" then getBranches(gitlabClient, res, command)
      when "version" then getVersion(gitlabClient, res)
      when "help" then sendHelp(res)
      else
        sendUnknownCommand(res, res.match[1])

createPipeline = (gitlabClient, res, command) ->
  if (command.length != 4 || command[1] != 'trigger')
    res.reply "Correct usage is gitlab pipeline trigger \<projectId\> \<branch\> "
    return

  projectId = command[2]
  branchName = command[3]

  gitlabClient.getBranches(projectId) (err, response, body) ->
    if err
      res.send "Encountered an error :( #{err}"
      return
    if response.statusCode isnt 200
      res.send "Request didn't come back HTTP 200 :( #{response.statusCode} #{body}"
      return

    data = JSON.parse body
    branch_names = []
    branch_names.push branch.name for branch in data

    filter_branch_names = (item for item in branch_names when item.indexOf(branchName) != -1)

    if filter_branch_names.length == 0
      res.reply "Sorry no branch found for #{branchName}. Here are the branches #{branch_names}"
      return

    if filter_branch_names.length > 1
      filter_branch_info = filter_branch_names.join('\n')
      res.reply "Sorry #{filter_branch_names.length} branches found for #{branchName}. Please be more specific. Here are the branches" + '\n' + "#{filter_branch_info}"
      return

    branch = filter_branch_names[0]

    gitlabClient.getTriggers(projectId) (err, response, body) ->
      if err
        res.send "Error while retrieving triggers :( #{err}"
        return
      if response.statusCode isnt 200
        res.send "Request didn't come back HTTP 200 :( #{response.statusCode} #{body}"
        return

      data = JSON.parse body
      if (data.length == 0)
        res.reply "No trigger found. Please create a trigger first"
      else
        trigger = data[0].token
        params = JSON.stringify({
          ref: branch,
          token: trigger
        })
        gitlabClient.triggerPipeline(projectId, params) (err, response, body) ->
          if err
            res.send ":( Error while creating pipeline with a trigger  #{err}"
            return
          if response.statusCode isnt 201
            res.send ":( Request didn't come back OK #{response2.statusCode} #{body}"
            return
          data2 = JSON.parse body
          res.reply "Pipeline #{data2.id} created on branch #{branch}"

getBranches = (gitlabClient, res, command) ->
  if (command.length != 2)
    res.reply "Correct usage is gitlab branches \<projectId\>"
    return
  projectId = command[1]
  gitlabClient.getBranches(projectId) (err, response, body) ->
    if err
      res.send "Encountered an error :( #{err}"
      return
    if response.statusCode isnt 200
      res.send "Request didn't come back HTTP 200 :( #{response.statusCode} #{body}"
      return
    data = JSON.parse body
    branch_infos = []
    branch_infos.push "#{branch.name}, last commit \"#{branch.commit.short_id}\", title \"#{branch.commit.title}\" by \"#{branch.commit.author_name}\" created at \"#{branch.commit.created_at}\"" for branch in data
    res.reply "#{data.length} branches found" + '\n' + branch_infos.join('\n')

getVersion = (gitlabClient, res) ->
  gitlabClient.version() (err, response, body) ->
    if err
      res.send "Encountered an error :( #{err}"
      return
    data = JSON.parse body
    res.reply "gitlab version is #{data.version}, revision #{data.revision}"

sendHelp = (res) ->
  res.reply 'Here are all the available commands:' + '\n' + HELP

sendUnknownCommand = (res, command) ->
  res.reply "Sorry, I did not understand command '" + command + "'. Here are all the available commands:" + '\n' + HELP


HELP_VERSION = "gitlab version - returns version"
HELP_DEFAULT = "gitlab help - displays all available commands"
HELP_PIPELINE = "gitlab pipeline trigger projectId branchName - triggers a pipeline on a branch matching branchName for the project with Id projectId"
HELP_BRANCH = "gitlab branches projectId - shows the branches for the project with Id projectId"

HELP = [HELP_PIPELINE, HELP_BRANCH, HELP_VERSION, HELP_DEFAULT].join('\n')

class GitlabClient
  constructor: (@robot, @url, @token) ->

  request = ->
    @robot.http(@url).header('Accept', 'application/json').header('PRIVATE-TOKEN', @token)

  version: () ->
    request.call(this).path('/api/v4/version').get()

  getTriggers: (projectId) ->
    request.call(this).path('/api/v4/projects/' + projectId + '/triggers').get()

  getBranches: (projectId) ->
    request.call(this).path('/api/v4/projects/' + projectId + '/repository/branches').get()

  triggerPipeline: (projectId, params) ->
    request.call(this).header('Content-type', 'application/json').path('/api/v4/projects/' + projectId + '/trigger/pipeline').post(params)
