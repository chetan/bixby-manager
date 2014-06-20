
class Bixby.CommandResponse extends Stark.View
  template: "runbooks/_command_response"

  isJSON: (str) ->
    str = str.trim()
    return str[0] == "{" && str[str.length-1] == "}"

  status_str: ->
    if @response.status == 0
      "success"
    else
      "error"

  after_render: ->
    @$("textarea").linedtextarea();
