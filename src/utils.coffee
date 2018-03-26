utils = {}

utils.buildListInfo = (data, callback) ->
  list = []
  list.push callback(branch) for branch in data
  return list


utils.parseResult = (res, err, response, successMethod, body, args...)->
  if err
    res.reply "Encountered an error :( #{err}"
    return
  if response.statusCode.toString().substr(0, 1)!="2"
    res.reply "Request Failed HTTP #{response.statusCode} Body [#{body}]"
    return
  successMethod(res, body, args...)

module.exports = utils
