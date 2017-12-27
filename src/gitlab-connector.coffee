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
      when "projects" then getProjects(gitlabClient, res, command)
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

  gitlabClient.getProject(projectId) (err, response, body) ->
    readProjectInfo(res, gitlabClient, projectId, branchName, err, response, body)

readProjectInfo = (res, gitlabClient, projectId, branchName, err, response, body) ->
  if err
    res.send "Encountered an error :( #{err}"
    return
  if response.statusCode isnt 200
    res.send "Request didn't come back HTTP 200 :( #{response.statusCode} #{body}"
    return
  project = JSON.parse body
  gitlabClient.getBranches(project.id) (err, response, body) ->
    findRightBranch(res, gitlabClient, project, branchName, err, response, body)

findRightBranch = (res, gitlabClient, project, branchName, err, response, body) ->
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
    branch_names_info=branch_names.join('\n')
    res.reply "Sorry no branch found for #{branchName}. Here are the branches" + '\n' + "#{branch_names_info}"
    return

  if filter_branch_names.length > 1
    filter_branch_info = filter_branch_names.join('\n')
    res.reply "Sorry #{filter_branch_names.length} branches found for #{branchName}. Please be more specific. Here are the branches" + '\n' + "#{filter_branch_info}"
    return
  branch = filter_branch_names[0]

  gitlabClient.getTriggers(project.id) (err, response, body) ->
    readTrigger(res, gitlabClient, project, branch, err, response, body)

readTrigger = (res, gitlabClient, project, branch, err, response, body)->
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
    gitlabClient.triggerPipeline(project.id, params) (err, response, body) ->
      parseTrigger(res, project, branch, err, response, body)

parseTrigger = (res, project, branch, err, response, body) ->
  if err
    res.send ":( Error while creating pipeline with a trigger  #{err}"
    return
  if response.statusCode isnt 201
    res.send ":( Request didn't come back OK #{response2.statusCode} #{body}"
    return
  data = JSON.parse body
  res.reply "Pipeline #{data.id} created on branch #{branch} of project #{project.name}. See #{project.web_url}/pipelines/#{data.id}"

getProjects = (gitlabClient, res, command) ->
  if (command.length != 2)
    res.reply "Correct usage is gitlab projects \<searchName\>"
    return
  searchName = command[1]
  gitlabClient.findProjects(searchName) (err, response, body) ->
    if err
      res.send "Encountered an error :( #{err}"
      return
    if response.statusCode isnt 200
      res.send "Request didn't come back HTTP 200 :( #{response.statusCode} #{body}"
      return
    data = JSON.parse body
    project_info = buildListInfo(data,formatProject)
    res.reply "#{data.length} projects found matching name #{searchName}" + '\n' + project_info.join('\n\n')

formatProject = (project) ->
  "#{project.name}, id:#{project.id}" + '\n' + "#{project.description}"+ '\n' + "  web url: #{project.web_url}, group: #{project.namespace.name}, last activity: #{project.last_activity_at}"


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
    branch_infos = buildListInfo(data,formatBranch)
    res.reply "#{data.length} branches found" + '\n' + branch_infos.join('\n\n')

buildListInfo = (data, callback) ->
  list = []
  list.push callback(branch) for branch in data
  return list

formatBranch = (branch) ->
  "#{branch.name}" + '\n' + "  last commit \"#{branch.commit.short_id}\", title \"#{branch.commit.title}\" by \"#{branch.commit.author_name}\" created at \"#{branch.commit.created_at}\""


getVersion = (gitlabClient, res) ->
  gitlabClient.version() (err, response, body)->
    readVersion(res, err, response, body)

readVersion = (res, err, response, body)->
  if err
    throw new Error(body);
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
HELP_PROJECT = "gitlab projects searchName - shows the projects whose name contains searchName"
HELP_BRANCH = "gitlab branches projectId - shows the branches for the project with Id projectId"

HELP = [HELP_PROJECT, HELP_PIPELINE, HELP_BRANCH, HELP_VERSION, HELP_DEFAULT].join('\n')

class GitlabClient
  constructor: (@robot, @url, @token) ->

  request = ->
    @robot.http(@url).header('Accept', 'application/json').header('PRIVATE-TOKEN', @token)

  version: () ->
    request.call(this).path('/api/v4/version').get()

  getTriggers: (projectId) ->
    request.call(this).path('/api/v4/projects/' + projectId + '/triggers').get()

  getProject: (projectId) ->
    request.call(this).path('/api/v4/projects/' + projectId).get()

  findProjects: (searchName) ->
    request.call(this).path('/api/v4/projects?search=' + searchName).get()

  getBranches: (projectId) ->
    request.call(this).path('/api/v4/projects/' + projectId + '/repository/branches').get()

  triggerPipeline: (projectId, params) ->
    request.call(this).header('Content-type', 'application/json').path('/api/v4/projects/' + projectId + '/trigger/pipeline').post(params)
