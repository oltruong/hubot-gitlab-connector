help = {}

help.sendHelp = (res) ->
  res.reply 'Here are all the available commands:' + '\n' + HELP

help.sendUnknownCommand = (res, command) ->
  res.reply "Sorry, I did not understand command '" + command + "'. Here are all the available commands:" + '\n' + HELP

HELP_VERSION = "gitlab version - returns version"
HELP_DEFAULT = "gitlab help - displays all available commands"
HELP_PIPELINE = "gitlab pipeline trigger projectId branchName - triggers a pipeline on a branch matching branchName for the project with Id projectId"
HELP_PROJECT = "gitlab projects searchName - shows the projects whose name contains searchName (optional)"
HELP_BRANCH = "gitlab branches projectId - shows the branches for the project with Id projectId"

HELP = [HELP_PROJECT, HELP_PIPELINE, HELP_BRANCH, HELP_VERSION, HELP_DEFAULT].join('\n')

module.exports = help
