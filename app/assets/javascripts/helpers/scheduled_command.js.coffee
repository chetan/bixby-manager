
namespace 'Bixby.helpers', (exports, top) ->
  exports.ScheduledCommand =
    schedule_type: (add_text) ->
      switch @scheduled_command.schedule_type
        when 1
          s = _.icon("refresh", null, "Cron job")
          s += " Cron" if add_text
          s
        when 2
          s = _.icon("calendar", null, "One time job")
          s += " Once" if add_text
          s

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
          ""

    date: (date) ->
      if date
        return date.format("L HH:mm:ss")
