utils = require("./utils")

getMergeRequests = (gitlabClient, res, command) ->
  if (gitlabClient? && res? && command?)
    if (command.length == 3)
      projectId = command[2]
      gitlabClient.getMergeRequests(projectId, "") (err, response, body) ->
        utils.parseResult(res, err, response, returnMergeRequests, body)
    else if (command.length == 4)
      projectId = command[2]
      gitlabClient.getMergeRequests(projectId, command[3]) (err, response, body) ->
        utils.parseResult(res, err, response, returnMergeRequests, body)
    else if (command.length == 4)
      projectId = command[2]
      gitlabClient.getMergeRequests(projectId, command[3]) (err, response, body) ->
        utils.parseResult(res, err, response, returnMergeRequests, body)
    else if (command.length == 5 && command[3] == "accept")
      projectId = command[2]
      gitlabClient.acceptMergeRequest(projectId, command[4]) (err, response, body) ->
        utils.parseResult(res, err, response, confirmMergeRequest, body)
    else
      res.reply "Correct usage is gitlab merge requests \<projectId\> \<filter>\ (optional, e.g. state=opened) or gitlab merge requests \<projectId\> accept \<merge iid\>"
    return

returnMergeRequests = (res, body)->
  data = JSON.parse body
  merge_infos = utils.buildListInfo(data, formatMerge)
  res.reply "#{data.length} merge requests found" + '\n' + merge_infos.join('\n\n')


formatMerge = (mergeRequest) ->
  "- id: #{mergeRequest.iid}, #{mergeRequest.title}, from #{mergeRequest.source_branch} to #{mergeRequest.target_branch}" + '\n' + "  state: #{mergeRequest.state.toUpperCase()}, updated at \"#{mergeRequest.updated_at}\", author: #{mergeRequest.author.name}" + '\n' + "  upvotes: #{mergeRequest.upvotes}, downvotes: #{mergeRequest.downvotes}" + '\n' + "  #{mergeRequest.web_url}"

confirmMergeRequest = (res, body)->
  data = JSON.parse body
  res.reply "merge request #{data.iid} is now #{data.state}. See #{data.web_url}"


module.exports = getMergeRequests
