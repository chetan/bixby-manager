namespace "Bixby", (exports, top) ->

  class exports.ScheduledCommand extends Stark.View
    el: "div#content"
    template: "runbooks/scheduled_command"
    helpers: [ Bixby.helpers.ScheduledCommand ]

    ui:
      prev: "li.older"
      next: "li.newer"

    links:
      "a.view_log": [ "runbooks_log", -> {command_log: @scheduled_command.command_log()} ]

    events:
      "click ul.dropdown-menu input": (e) ->
        e.preventDefault()
        e.stopPropagation()

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

      if @command_logs.length < 10
        @ui.next.addClass("disabled")
      else
        @ui.next.removeClass("disabled")
