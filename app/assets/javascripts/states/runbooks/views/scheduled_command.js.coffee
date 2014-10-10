namespace "Bixby", (exports, top) ->

  class exports.ScheduledCommand extends Stark.View
    el: "div#content"
    template: "runbooks/scheduled_command"
    helpers: [ Bixby.helpers.ScheduledCommand ]

    ui:
      prev: "li.older"
      next: "li.newer"
      toggle: "button.toggle"

    events:
      "click ul.dropdown-menu input": (e) ->
        e.preventDefault()
        e.stopPropagation()

      "click button.cancel": ->

      "click button.toggle": ->
        if @scheduled_command.enabled
          @scheduled_command.disable =>
            @redraw()
        else
          @scheduled_command.enable =>
            @redraw()

      "click prev": ->
        return if @ui.prev.hasClass("disabled")
        @command_logs.getPreviousPage().done =>
          @redraw()

      "click next": ->
        return if @ui.next.hasClass("disabled")
        @command_logs.getNextPage().done =>
          @redraw()

    after_render: ->
      if @scheduled_command.enabled
        @ui.toggle.removeClass("btn-success").addClass("btn-warning").text("Disable")
      else
        @ui.toggle.removeClass("btn-warning").addClass("btn-success").text("Enable")


      if @command_logs.state.currentPage == 1
        @ui.prev.addClass("disabled")
      else
        @ui.prev.removeClass("disabled")

      if @command_logs.length < 10
        @ui.next.addClass("disabled")
      else
        @ui.next.removeClass("disabled")
