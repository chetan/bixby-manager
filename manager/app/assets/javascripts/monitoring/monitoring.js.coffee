
jQuery ->

  _bv = Bixby.view
  _vn = _bv.monitoring
  _bm = Bixby.model
  Bixby.app.add_state(
    class MonViewHostState extends Stark.State
      name: "mon_view_host" #  canonical name used for state transitions
                            #  e.g., it is referred to in events hash of other states

      url:  "monitoring/hosts/:host_id" #  match() pattern [optional]

      views:      [ _bv.PageLayout, _vn.Layout, _vn.ResourceList ]
      no_redraw:  [ _bv.PageLayout, _vn.Layout ]
      models:     { host: _bm.Host, resources: _bm.ResourceList }

      events: {
        mon_hosts_resources_new: { models: [ _bm.Host ] }
      }

      create_url: ->
        @url.replace /:host_id/, @host.id

      load_data: ->
        needed = []
        if ! @host?
          @host = new _bm.Host({ id: @params.host_id })
          needed.push @host

        if ! @resources?
          host_id = (@params? && @params.host_id) || @host.id
          @resources = new _bm.ResourceList(host_id)
          needed.push @resources

        return needed

      activate: ->
        @app.trigger("nav:select_tab", "monitoring")

        @resources.each (res) ->
          metrics = res.get("metrics");
          _.each metrics, (val, key) ->
            s = ".resource[resource_id=" + res.id + "] .metric[metric='" + key + "']"
            el = $(s + " .graph")[0]
            graph = new Rickshaw.Graph( {
              element: el,
              width: 300,
              height: 100,
              series: [ {
                color: 'steelblue',
                data: val.vals
              } ]
            } );
            graph.render();
            $(s + " .footer").text(sprintf("Last Value: %0.2f", val.vals[val.vals.length-1].y));

  )

  Bixby.app.add_state(
    class extends Stark.State
      name: "mon_hosts_resources_new"
      url:  "monitoring/hosts/:host_id/resources/new"

      views:      [ _bv.PageLayout, _vn.Layout, _vn.AddCommand ]
      no_redraw:  [ _bv.PageLayout, _vn.Layout ]
      models:     { host: _bm.Host, commands: _bm.MonitoringCommandList }

      create_url: ->
        @url.replace /:host_id/, @host.id

      load_data: ->
        needed = []
        if ! @host?
          @host = new _bm.Host({ id: @params.host_id })
          needed.push @host

        if ! @commands
          @commands = new _bm.MonitoringCommandList()
          needed.push @commands

        return needed
  )

  Bixby.app.add_state(
    class extends Stark.State
      name: "mon_hosts_resources_new_opts"
      views:      [ _bv.PageLayout, _vn.Layout, _vn.AddCommand, _vn.AddCommandOpts ]
      no_redraw:  [ _bv.PageLayout, _vn.Layout, _vn.AddCommand ]
      models:     { host: _bm.Host, commands: _bm.MonitoringCommandList }
      load_data: ->
        @spinner = new _bv.Spinner($("div.command_opts"))
        return @commands

      activate: ->
        @spinner.stop()

  )

