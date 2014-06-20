
class Bixby.CommandResponse extends Stark.View
  template: "runbooks/_command_response"

  status_str: ->
    if @response.status == 0
      "success"
    else
      "error"

  after_render: ->
    @$("textarea").linedtextarea();
