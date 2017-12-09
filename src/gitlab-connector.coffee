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

    command = res.match[1]

    switch command
      when "project" then listProject(robot, res, url, token)
      when "version" then sendVersion(robot, res, url, token)
      when "help" then sendHelp(res)
      else
        sendUnknownCommand(res)


#    if command is "project"
#
#    else if command is "help"
#
#    else

listProject = (robot, res, url, token) ->
  robot.http('http://gitlab.com').header('Accept', 'application/json').path('/hello').get() (err, response, body) ->
    res.reply body

#  res.reply "hello"
sendVersion = (robot, res, url, token) ->
  robot.http('http://gitlab.com')
    .header('Accept', 'application/json')
    .path('/version')
    .get() (err, response, body) ->
    res.reply body

sendHelp = (res) ->
  res.reply "help's on the way"

sendUnknownCommand = (res) ->
  res.reply "Sorry I did not understand. 'gitlab help' will provide you with all available commands"




