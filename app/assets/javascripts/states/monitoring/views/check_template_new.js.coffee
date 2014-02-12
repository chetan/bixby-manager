
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckTemplateNew extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/check_template_new"

    events:
      "click #submit_check": (e) ->

        if $("h3#configure").length > 0
          # cheap hack to short-circuit double-bound event when opts view is displayed as well
          return

        # show options for selected commands/checks
        opts = []

        # filter the list of commands to include only the ones we have selected
        selected_commands = new Bixby.model.MonitoringCommandList()

        $("input.checkbox:checked").eachR @, (idx, el) ->
          opt = new Bixby.model.MonitoringCommandOpts({ id: el.value })
          opt.host = @host
          opts.push opt
          selected_commands.add @commands.get(el.value)

        if opts.length > 0
          @transition "mon_check_template_new_opts",
            {
              tags: @tags
              opts: opts
              commands: selected_commands
              hosts: @state.hosts
              name: _.val(@$("#name"))
              mode: _.val(@$("#mode"))
              selected_tags: _.val(@$("#tags"))
            }

    after_render: ->
      @$("select.mode").select2({minimumResultsForSearch: -1}) # -1 disables search input
      @$("select#mode").select2("val", @mode) if @mode?

      @$("input.tags").select2({
        tags: @tags.get()
        tokenSeparators: [",", " "]
      })
