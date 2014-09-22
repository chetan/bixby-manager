namespace "Bixby", (exports, top) ->

  class exports.CommandLogs extends Stark.View
    el: "div#content"
    template: "runbooks/command_logs"

    events: {}

    status: (log) ->
      if log.exec_status == true
        # ran successfully, check the actual command's status
        if log.status == 0
          return "success"
        else
          return "fail (#{log.status})"
      return "fail"
