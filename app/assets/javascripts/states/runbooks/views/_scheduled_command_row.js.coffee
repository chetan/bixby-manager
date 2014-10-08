namespace "Bixby.view", (exports, top) ->

  class exports.ScheduledCommandRow extends Stark.Partial
    className: "scheduled_command_row"
    template: "runbooks/_scheduled_command_row"

    links:
      "a": [ "scheduled_command", -> { scheduled_command: @scheduled_command } ]

    schedule_type: ->
      switch @scheduled_command.schedule_type
        when 1
          "Cron"
        when 2
          "Once"

    schedule: ->
      switch @scheduled_command.schedule_type
        when 1
          @scheduled_command.schedule
        when 2
          @scheduled_command.scheduled_at.format("L HH:mm:ss")

    status: ->
      switch @scheduled_command.status
        when "success"
          return _.icon("check", "fa-lg success", "Success")
        when "fail"
          return _.icon("times", "fa-lg danger", "Fail")
        else
          return _.icon("clock-o", "fa-lg warning", "Pending")
