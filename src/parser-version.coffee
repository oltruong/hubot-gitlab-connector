getVersion = (gitlabClient, res) ->
  gitlabClient.getVersion() (err, response, body)->
    parseResult(res, err, response, body, readVersion)

parseResult = (res, err, response, body, successMethod)->
  if err
    throw new Error(body);
    res.send "Encountered an error :( #{err}"
    return
  if response.statusCode isnt 200
    res.send "Request didn't come back HTTP 200 :( #{response.statusCode} #{body}"
    return
  successMethod(res, body)

readVersion = (res, body)->
  data = JSON.parse body
  res.reply "gitlab version is #{data.version}, revision #{data.revision}"

module.exports = getVersion
