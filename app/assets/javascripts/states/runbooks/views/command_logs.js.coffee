namespace "Bixby", (exports, top) ->

  class exports.CommandLogs extends Stark.View
    el: "div#content"
    template: "runbooks/command_logs"

    ui:
      prev: "li.older"
      next: "li.newer"

    events:
      "click prev": ->
        return if @ui.prev.hasClass("disabled")
        @command_logs.getPreviousPage().done =>
          @redraw()

      "click next": ->
        return if @ui.next.hasClass("disabled")
        @command_logs.getNextPage().done =>
          @redraw()

    status: (log) ->
      if log.exec_status == true
        # ran successfully, check the actual command's status
        if log.status == 0
          return _.icon("check", "fa-lg success")

      return _.icon("times", "fa-lg danger")

    after_render: ->
      if @command_logs.state.currentPage == 1
        @ui.prev.addClass("disabled")
      else
        @ui.prev.removeClass("disabled")

      if @command_logs.length < 25
        @ui.next.addClass("disabled")
      else
        @ui.next.removeClass("disabled")
