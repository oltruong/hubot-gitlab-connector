utils = require("./utils")

getVersion = (gitlabClient, res) ->
  gitlabClient.getVersion() (err, response, body)->
    utils.parseResult(res, err, response, readVersion,body)

readVersion = (res, body)->
  data = JSON.parse body
  res.reply "gitlab version is #{data.version}, revision #{data.revision}"

module.exports = getVersion
