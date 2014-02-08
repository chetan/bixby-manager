
#= require_tree "./views"

Bixby.app.add_states { tab: "inventory", views: [_bv.PageLayout, _vi.Layout] },

  "getting_started":
    url:  "getting_started"

    views:      _vi.GettingStarted
    models:     { hosts: Bixby.model.HostList } # needed for validation

    validate: ->
      if @hosts? && !@hosts.isEmpty()
        @transition "inventory", {hosts: @hosts}
        return false
      return true

  "inventory":
    url:  "inventory"

    views:      _vi.HostTable
    models:     { hosts: Bixby.model.HostList }

    validate: ->
      if !@hosts? or @hosts.isEmpty()
        @transition "getting_started", {hosts: @hosts}
        return false
      return true

  "inv_view_host":
    url:  "inventory/hosts/:host_id"

    views:      _vi.Host
    models:     { host: Bixby.model.Host }

  "inv_search":
    class extends Stark.State
      url: "inventory/search/:query"

      views:      [ _vi.HostSearchHeader, _vi.HostTable ]
      models:     { hosts: Bixby.model.HostList, query: "" }

      create_url: ->
        return super().replace(/#/, '%23')

      activate: ->
        @app.trigger("search:set_query", @query)

      load_data: (data) ->

        if data.query?
          @query = data.query
        else if data.params
          data.query = @query = data.params.query
        else
          @query = ""

        needed = super(data)
        _.eachR @, needed, (n) ->
          if n instanceof Bixby.model.HostList
            n.query = @query

        return needed
