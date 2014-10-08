namespace "Bixby", (exports, top) ->

  class exports.ScheduledCommands extends Stark.View
    el: "div#content"
    template: "runbooks/scheduled_commands"

    ui:
      tab:
        active: "a.active"
        history: "a.history"

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
      @tab = @state.page_tab
      @ui.tab[@tab].parent().addClass("active")
