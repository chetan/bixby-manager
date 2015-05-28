
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
          @format_datetime(@scheduled_command.scheduled_at)

    last_run_status: ->
      return "" if !@scheduled_command.last_run_status

      if @scheduled_command.last_run_status == 1
        return _.icon("check", "fa-lg success", "Success")
      else
        return _.icon("times", "fa-lg danger", "Fail")
