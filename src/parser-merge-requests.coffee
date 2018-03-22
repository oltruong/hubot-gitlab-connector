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
    else if (command.length == 8 && command[3] == "accept" && command[4] == "from" && command[6] == "to")
      projectId = command[2]
      source_branch=  command[5]
      target_branch=  command[7]
      gitlabClient.getMergeRequests(projectId, "state=opened&source_branch="+source_branch+"&target_branch="+target_branch) (err, response, body) ->
        utils.parseResult(res, err, response, acceptOneMergeRequest, body,gitlabClient,projectId,source_branch,target_branch)
    else
      res.reply "Correct usage is gitlab merge requests \<projectId\> \<filter>\ (optional, e.g. state=opened) or gitlab merge requests \<projectId\> accept \<merge iid\> or gitlab merge requests <projectId> accept accept from \<sourceBranch\> to \<targetBranch\>"
    return

returnMergeRequests = (res, body)->
  data = JSON.parse body
  merge_infos = utils.buildListInfo(data, formatMerge)
  res.reply "#{data.length} merge requests found" + '\n' + merge_infos.join('\n\n')

acceptOneMergeRequest = (res, body,gitlabClient,projectId,source_branch,target_branch)->
  data = JSON.parse body
  merge_requests_iid = []
  merge_requests_iid.push mr.iid for mr in data
  if merge_requests_iid.length == 0
    res.reply "Sorry no merge request opened found from #{source_branch} to #{target_branch}"
  else
    merge_request_iid = merge_requests_iid[0]
    gitlabClient.acceptMergeRequest(projectId, merge_request_iid) (err, response, body) ->
      utils.parseResult(res, err, response, confirmMergeRequest, body)

formatMerge = (mergeRequest) ->
  "- id: #{mergeRequest.iid}, #{mergeRequest.title}, from #{mergeRequest.source_branch} to #{mergeRequest.target_branch}" + '\n' + "  state: #{mergeRequest.state.toUpperCase()}, updated at \"#{mergeRequest.updated_at}\", author: #{mergeRequest.author.name}" + '\n' + "  upvotes: #{mergeRequest.upvotes}, downvotes: #{mergeRequest.downvotes}" + '\n' + "  #{mergeRequest.web_url}"

confirmMergeRequest = (res, body)->
  data = JSON.parse body
  res.reply "merge request #{data.iid} is now #{data.state}.\nSee #{data.web_url}"


module.exports = getMergeRequests
