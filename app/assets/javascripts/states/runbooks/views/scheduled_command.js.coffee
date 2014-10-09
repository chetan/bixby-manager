namespace "Bixby", (exports, top) ->

  class exports.ScheduledCommand extends Stark.View
    el: "div#content"
    template: "runbooks/scheduled_command"
    helpers: [ Bixby.helpers.ScheduledCommand ]

    links:
      "a.view_log": [ "runbooks_log", -> {command_log: @scheduled_command.command_log()} ]

    events:
      "click ul.dropdown-menu input": (e) ->
        e.preventDefault()
        e.stopPropagation()
