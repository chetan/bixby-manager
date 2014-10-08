namespace "Bixby", (exports, top) ->

  class exports.ScheduledCommands extends Stark.View
    el: "div#content"
    template: "runbooks/scheduled_commands"

    ui:
      tab:
        active: "a.active"
        history: "a.history"
      pane:
        active: "div#active"
        history: "div#history"

    events:
      "show.bs.tab": (e) ->
        new_tab = $(e.target).attr("class")
        if new_tab != @tab
          new_state = if new_tab == "history"
            "scheduled_commands_history"
          else
            "scheduled_commands"
          @transition(new_state)

    after_render: ->
      @log @state
      @tab = @state.page_tab
      @log "tab: ", @tab
      @ui.tab[@tab].parent().addClass("active")
      @ui.pane[@tab].addClass("active")
      html = @include_partial(B.ScheduledCommandsTable, {scheduled_commands: @scheduled_commands})
      @ui.pane[@tab].html(html)

