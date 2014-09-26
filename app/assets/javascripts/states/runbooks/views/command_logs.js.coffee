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

    after_render: ->
      if @command_logs.state.currentPage == 1
        @ui.prev.addClass("disabled")
      else
        @ui.prev.removeClass("disabled")

      if @command_logs.length < 25
        @ui.next.addClass("disabled")
      else
        @ui.next.removeClass("disabled")
