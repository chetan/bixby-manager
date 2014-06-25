
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

  status_str: ->
    if @response.status == 0
      "success"
    else
      "error"

  after_render: ->
    @$("textarea").linedtextarea();
