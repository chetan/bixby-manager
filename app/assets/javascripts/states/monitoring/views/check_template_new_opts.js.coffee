
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckTemplateNewOpts extends Stark.View
    el: "div.command_opts"
    template: "monitoring/add_command_opts"

    events: ->
      # we use a normal jquery binding here because the button actually belongs
      # to another view (CheckTemplateNew)
      view = @
      $("#submit_check").on "click", null, (e) ->
        # create the commands
        checks = []
        _.each view.opts, (cmd) ->
          check = new Bixby.model.CheckTemplateItem()
          check.set { command_id: cmd.id }

          args = {}
          # gather values
          _.each cmd.get("options"), (opt_hash, opt) ->
            args[opt] = view.$("##{opt}").val()

          # set runhost if exists
          # TODO handle this later
          if view.$("#runhost").length > 0
            check.set("runhost_id", view.$("#runhost").val())

          check.set({ args: args })
          checks.push check

        Backbone.multi_save checks, (err, results) ->
          view.transition "monitoring"

      return {} # return empty event hash to backbone delegateEvents

    # Get option name for display. Shows default value if present.
    # e.g., Foo Option [default: ``blah``]
    #
    # @return [String]
    opt_name: (key, hash) ->
      s = (hash["name"] || _.split_cap(key))
      if hash["default"]?
        s += " [default: ``#{hash['default']}``]"
      @markdown(s)
