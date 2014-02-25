namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.AddCommandOpts extends Stark.View
    el: "div.command_opts"
    template: "monitoring/add_command_opts"

    events: ->
      # we use a normal jquery binding here because the button actually belongs
      # to another view (AddCommand)
      view = @
      $("#submit_check").on "click", null, (e) ->
        # create the commands
        checks = []
        _.each view.opts, (cmd) ->
          check = new Bixby.model.Check()
          check.host = cmd.host
          check.set { command_id: cmd.id, host_id: cmd.host.id }

          args = {}
          # gather values
          _.each cmd.get("options"), (opt_hash, opt) ->
            args[opt] = view.$("##{opt}").val()

          # set runhost if exists
          if view.$("#runhost").length > 0
            check.set("runhost_id", view.$("#runhost").val())

          check.set({ args: args })
          checks.push check

        Backbone.multi_save checks, (err, results) ->
          view.host.update_check_config() # fire and forget, no callback here
          view.transition "mon_view_host", { host: view.host }

      return {} # return empty event hash to backbone delegateEvents
