
namespace 'Bixby.helpers', (exports, top) ->
  exports.ScheduledCommand =
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

    date: (date) ->
      if date
        return date.format("L HH:mm:ss")
