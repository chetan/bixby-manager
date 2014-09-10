
#= require_tree "./views"

help =
  check_templates: "Check templates allow you to easily apply a set of checks to hosts matching specific criteria (e.g., all hosts tagged 'mysql'). The templates are applied when the host is first added to Bixby."

Bixby.app.add_states { tab: "monitoring", views: [_bv.PageLayout, _bvm.Layout] },

  # Check templates home
  "mon_check_templates":
    url:    "monitoring/check_templates"
    help:   help.check_templates

    views:  [ _bvm.CheckTemplateIndex ]
    models:
      check_templates: _bm.CheckTemplateList

  "mon_check_template_view":
    url:  "monitoring/check_templates/:check_template_id"
    help:   help.check_templates

    views: _bvm.CheckTemplateView
    models:
      check_template: _bm.CheckTemplate

  "mon_check_template_new":
    url:  "monitoring/check_templates/new"
    help:   help.check_templates

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
