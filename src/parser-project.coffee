utils = require("./utils")

getProjects = (gitlabClient, res, command) ->
  if (command.length == 1)
    gitlabClient.getProjects() (err, response, body) ->
      readProjects(res, err, response, body)
  else if (command.length == 2)
    searchName = command[1]
    gitlabClient.getProjectsByName(searchName) (err, response, body) ->
      readProjects(res, err, response, body)
  else
    res.reply "Correct usage is 'gitlab projects' or gitlab projects \<searchName\>'"
    return

readProjects = (res, err, response, body)->
  utils.parseResult(res, err, response, body, returnProject)


returnProject = (res, body)->
  data = JSON.parse body
  project_info = utils.buildListInfo(data, formatProject)
  res.reply "#{data.length} projects found." + '\n' + project_info.join('\n\n\n')

formatProject = (project) ->
  "- #{project.name}, id:#{project.id}" + '\n' + "  #{project.description}" + '\n' + "  web url: #{project.web_url}, group: #{project.namespace.name}, last activity: #{project.last_activity_at}"


module.exports = getProjects
