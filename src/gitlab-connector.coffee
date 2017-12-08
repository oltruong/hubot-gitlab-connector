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


# /api/v4/projects?search=caravan"

module.exports = (robot) ->
  robot.respond /gitlab (.*)/, (res) ->
    url = process.env.HUBOT_GITLAB_URL
    token = process.env.HUBOT_GITLAB_TOKEN

    command = res.match[1]

    switch command
      when "project" then listProject(res,url,token)
      when "help" then sendHelp(res)
      else
        sendUnknownCommand(res)


#    if command is "project"
#
#    else if command is "help"
#
#    else

listProject = (res,url,token) ->
#  robot.http(url)
#    .header('Accept', 'application/json')
#    .get() (err, res, body) ->
#    data = JSON.parse body
  res.reply "hello!"

sendHelp = (res) ->
  res.reply "help's on the way"

sendUnknownCommand = (res) ->
  res.reply "Sorry I did not understand. 'gitlab help' will provide you with all available commands"




