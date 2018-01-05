utils = require("./utils")

getBranches = (gitlabClient, res, command) ->
  if (command.length != 2)
    res.reply "Correct usage is gitlab branches \<projectId\>"
    return
  projectId = command[1]
  gitlabClient.getBranches(projectId) (err, response, body) ->
    utils.parseResult(res, err, response,  returnBranches,body)

returnBranches = (res, body)->
  data = JSON.parse body
  branch_infos =  utils.buildListInfo(data, formatBranch)
  res.reply "#{data.length} branches found" + '\n' + branch_infos.join('\n\n')


formatBranch = (branch) ->
  "- #{branch.name}" + '\n' + "  last commit \"#{branch.commit.short_id}\", title \"#{branch.commit.title}\" by \"#{branch.commit.author_name}\" created at \"#{branch.commit.created_at}\""


module.exports = getBranches
