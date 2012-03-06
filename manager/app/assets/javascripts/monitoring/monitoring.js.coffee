
jQuery ->

  _vn = Bixby.view.monitoring
  Bixby.app.add_state(
    class MonViewHostState extends Stark.State
      name: "mon_view_host" #  canonical name used for state transitions
                            #  e.g., it is referred to in events hash of other states

      url:  "monitoring/hosts/:host_id" #  match() pattern [optional]

      views:      [ Bixby.view.PageLayout, _vn.Layout, _vn.ResourceList ]
      no_redraw:  [ Bixby.view.PageLayout, _vn.Layout ]
      models:     { host: Bixby.model.Host, resources: Bixby.model.ResourceList }

      events: {
        mon_hosts_resources_new: { models: [ Bixby.model.Host ] }
      }

      create_url: ->
        @url.replace /:host_id/, @host.id

      load_data: ->
        needed = []
        if ! @host?
          @host = new Bixby.model.Host({ id: @params.host_id })
          needed.push @host

        if ! @resources?
          host_id = (@params? && @params.host_id) || @host.id
          @resources = new Bixby.model.ResourceList(host_id)
          needed.push @resources

        return needed

      activate: ->
        @app.trigger("nav:select_tab", "monitoring")
  )

  Bixby.app.add_state(
    class extends Stark.State
      name: "mon_hosts_resources_new"
      url:  "monitoring/hosts/:host_id/resources/new"

      views:      [ Bixby.view.PageLayout, _vn.Layout, _vn.AddCommand ]
      no_redraw:  [ Bixby.view.PageLayout, _vn.Layout ]
      models:     { host: Bixby.model.Host, commands: Bixby.model.MonitoringCommandList }

      create_url: ->
        @url.replace /:host_id/, @host.id

      load_data: ->
        needed = []
        if ! @host?
          @host = new Bixby.model.Host({ id: @params.host_id })
          needed.push @host

        if ! @commands
          @commands = new Bixby.model.MonitoringCommandList()
          needed.push @commands

        return needed
  )

  Bixby.app.add_state(
    class extends Stark.State
      name: "mon_hosts_resources_new_opts"
      views:      [ Bixby.view.PageLayout, _vn.Layout, _vn.AddCommand, _vn.AddCommandOpts ]
      no_redraw:  [ Bixby.view.PageLayout, _vn.Layout, _vn.AddCommand ]
      models:     { host: Bixby.model.Host, commands: Bixby.model.MonitoringCommandList }
      load_data: ->
        @spinner = new Bixby.view.Spinner($("div.command_opts"))
        return @commands

      activate: ->
        @spinner.stop()

  )

