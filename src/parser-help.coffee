help = {}

help.sendHelp = (res) ->
  res.reply 'Here are all the available commands:' + '\n' + HELP

help.sendUnknownCommand = (res, command) ->
  res.reply "Sorry, I did not understand command '" + command + "'. Here are all the available commands:" + '\n' + HELP

HELP_BRANCH = "gitlab branches projectId - shows the branches for the project whose id is projectId"
HELP_PIPELINE = "gitlab pipeline trigger projectId branchName - triggers a pipeline on a branch matching branchName for the project  whose id is projectId"
HELP_MERGE_REQUEST = "gitlab merge request projectId filter - shows the merge requests for the project whose id is projectId with filter(optional, e.g. state=opened)"
HELP_MERGE_REQUEST_ACCEPT = "gitlab merge request projectId accept merge_iid - accepts the merge request iid for the project whose id is projectId"
HELP_MERGE_REQUEST_ACCEPT_BRANCH = "gitlab merge request projectId accept from A to B - accepts the merge request from source branch A to target branch B for the project whose id is projectId"
HELP_VERSION = "gitlab version - returns version"
HELP_PROJECT = "gitlab projects searchName - shows the projects whose name contains searchName (optional)"
HELP_DEFAULT = "gitlab help - displays all available commands"

HELP = [HELP_BRANCH,HELP_PROJECT,HELP_MERGE_REQUEST,HELP_MERGE_REQUEST_ACCEPT,HELP_MERGE_REQUEST_ACCEPT_BRANCH, HELP_PIPELINE,  HELP_VERSION, HELP_DEFAULT].join('\n')

module.exports = help
