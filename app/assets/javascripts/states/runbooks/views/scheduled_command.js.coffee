namespace "Bixby", (exports, top) ->

  class exports.ScheduledCommand extends Stark.View
    el: "div#content"
    template: "runbooks/scheduled_command"
    helpers: [ Bixby.helpers.ScheduledCommand ]

    ui:
      prev: "li.older"
      next: "li.newer"
      toggle: "button.toggle"
      repeat: "div.repeat_command li a"

    events:
      "click ul.dropdown-menu input": (e) ->
        e.preventDefault()
        e.stopPropagation()

      "click button.cancel": ->
        @scheduled_command.destroy
          success: =>
            @transition("scheduled_commands")

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

      "click repeat": (e) ->
        d = moment(new Date())
        switch $(e.target).attr("class")
          when "now"
            @reschedule(d)
          when "5min"
            d.add(5, "minutes")
            @reschedule(d)
          when "1hour"
            d.add(1, "hours")
            @reschedule(d)
          when "custom"
            null

    reschedule: (time) ->
      @scheduled_command.repeat time, (new_sc) =>
        @transition "scheduled_command", { scheduled_command: new_sc }

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
