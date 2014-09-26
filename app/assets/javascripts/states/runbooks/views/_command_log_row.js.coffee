namespace "Bixby.view", (exports, top) ->

  class exports.CommandLogRow extends Stark.Partial
    className: "command_log_row"
    template: "runbooks/_command_log_row"

    links:
      "a": [ "runbooks_log", -> { command_log: @command_log } ]

    status: ->
      if @command_log.exec_status == true && @command_log.status == 0
        return _.icon("check", "fa-lg success", "Success")
      return _.icon("times", "fa-lg danger", "Fail")

    after_render: ->
      # override the link event created earlier in order to show a modal here
      @delegateEvents
        "click a": (e) ->
          e.preventDefault()
          e.stopPropagation()
          modal = @partial(exports.CommandLogModal, { command_log: @command_log }).show()
