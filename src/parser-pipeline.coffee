utils = require("./utils")

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
    branch_names_info = branch_names.join('\n')
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

module.exports = createPipeline
