namespace "Bixby.view", (exports, top) ->

  class exports.ScheduledCommandRow extends Stark.Partial
    className: "scheduled_command_row"
    template: "runbooks/_scheduled_command_row"

    helpers: [ Bixby.helpers.ScheduledCommand ]

    links:
      "a": [ "scheduled_command", -> { scheduled_command: @scheduled_command } ]
