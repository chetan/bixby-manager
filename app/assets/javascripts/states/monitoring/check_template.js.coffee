
#= require_tree "./views"

Bixby.app.add_states { tab: "monitoring", views: [_bv.PageLayout, _bvm.Layout] },

  "mon_check_template_new":
    url:  "monitoring/check_templates/new"

    views: _bvm.CheckTemplateNew
    models:
      commands: _bm.MonitoringCommandList
      tags:     _bm.HostTagList

    activate: ->
      # preload hosts in the background
      if !@hosts?
        @hosts = new _bm.HostList
        Backbone.multi_fetch(@hosts)

  "mon_check_template_new_opts":
    class extends Stark.State
      url:  "#configure"

      views: [ _bvm.CheckTemplateNew, _bvm.CheckTemplateNewOpts ]
      models:
        commands: _bm.MonitoringCommandList
        tags:     _bm.HostTagList
        opts:     _bm.MonitoringCommandOpts

      load_data: (data) ->
        needed = super(data)

        # only load opts for checks which have/need them
        opts_needed = []
        _.eachR @, @opts, (opt) ->
          cmd = @commands.get(opt.id)
          cmd.checked = true
          opt.set(cmd.attributes, {silent: true})
          @log cmd

        needed = _.union(needed, opts_needed)
        @spinner = new _bv.Spinner($("div.command_opts").height(30).css({ padding: "20px" }))
        return needed

      activate: ->
        @spinner.stop()
        $("a#submit_check").html("Add Check(s)")

  "mon_check_template_view":
    url:  "monitoring/check_templates/:check_template_id"

    views: _bvm.CheckTemplateNew
    models:
      check_template: _bm.CheckTemplate
      commands: _bm.MonitoringCommandList
