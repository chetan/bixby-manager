
class Bixby.CommandResponse extends Stark.View
  template: "runbooks/_command_response"

  # Test if a string looks like JSON
  # The string is considered to be JSON if looks like either an Object or Array
  #
  # @param [String] str
  #
  # @return [Boolean]
  isJSON: (str) ->
    str = str.trim()
    a = str[0]
    b = str[str.length-1]
    return (a == "{" && b == "}") || (a == "[" && b == "]")

  num_bytes: (str) ->
    if !str || str.length == 0
      return "0 bytes"

    s = "#{str.length} byte"
    if str.length != 1
      s += "s"
    return s

  num_lines: (str) ->
    if !str || str.length == 0
      return "0 lines"

    lines = str.split("\n")
    s = "#{lines.length} line"
    if lines.length != 1
      s += "s"
    return s


  status_str: ->
    if @response.status == 0
      "success"
    else
      "error"

  after_render: ->
    @$("textarea").linedtextarea();
