namespace "Bixby", (exports, top) ->

  class exports.CommandLogs extends Stark.View
    el: "div#content"
    template: "runbooks/command_logs"

    ui:
      prev: "button.previous"
      next: "button.next"

    events:
      "click prev": ->
        @command_logs.getPreviousPage().done =>
          @redraw()

      "click next": ->
        @command_logs.getNextPage().done =>
          @redraw()

    status: (log) ->
      if log.exec_status == true
        # ran successfully, check the actual command's status
        if log.status == 0
          return "success"
        else
          return "fail (#{log.status})"
      return "fail"

    after_render: ->
      if @command_logs.state.currentPage == 1
        @ui.prev.addClass("disabled")
      else
        @ui.prev.removeClass("disabled")

      if @command_logs.length < 25
        @ui.next.addClass("disabled")
      else
        @ui.next.removeClass("disabled")
