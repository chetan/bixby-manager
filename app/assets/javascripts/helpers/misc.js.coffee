
# setTimeoutR - allows passing timeout as first param
window.setTimeoutR = (timeout, func) ->
  window.setTimeout(func, timeout)

# Get a hash of all URL query parameters
_.params = ->
  regex = /[?&]([^=#]+)=([^&#]*)/g
  url = window.location.href
  params = {}
  match = null

  while match = regex.exec(url)
    params[match[1]] = match[2]

  return params

# Get a URL query parameter by key
_.param = (key) ->
  _.params()[key]
