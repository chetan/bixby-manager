
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckTemplateNewOpts extends Stark.View
    el: "div.command_opts"
    template: "monitoring/add_command_opts"

    events: ->
      # we use a normal jquery binding here because the button actually belongs
      # to another view (CheckTemplateNew)
      view = @
      $("#submit_check").on "click", null, (e) ->

        template = new Bixby.model.CheckTemplate()
        template.set {
          name: _.val($("#name"))
          mode: _.val($("#mode"))
          tags: _.val($("#tags"))
          items: []
        }

        # create the commands
        _.each view.opts, (cmd) ->
          check = { command_id: cmd.id }

          args = {}
          # gather values
          _.each cmd.get("options"), (opt_hash, opt) ->
            args[opt] = view.$("##{opt}").val()
          check.args = args

          # set runhost if exists
          # TODO handle this later
          if view.$("#runhost").length > 0
            check.runhost_id = view.$("#runhost").val()

          template.attributes.items.push check

        view.log template
        Backbone.multi_save template, (err, results) ->
          view.transition "monitoring"

      return {} # return empty event hash to backbone delegateEvents

    # Get option name for display. Shows default value if present.
    # e.g., Foo Option [default: ``blah``]
    #
    # @return [String]
    opt_name: (key, hash) ->
      s = (hash["name"] || _.split_cap(key))
      if hash["default"]?
        s += "<br/><span class='default-opt'>[default: ``#{hash['default']}``]</span>"
      @markdown(s)
