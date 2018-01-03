utils = {}

utils.buildListInfo = (data, callback) ->
  list = []
  list.push callback(branch) for branch in data
  return list


utils.parseResult = (res, err, response, body, successMethod)->
  if err
    throw new Error(body);
    res.send "Encountered an error :( #{err}"
    return
  if response.statusCode isnt 200
    res.send "Request didn't come back HTTP 200 :( #{response.statusCode} #{body}"
    return
  successMethod(res, body)


module.exports = utils
