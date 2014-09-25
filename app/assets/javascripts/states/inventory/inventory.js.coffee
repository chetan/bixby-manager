
#= require_tree "./views"

Bixby.app.add_states { tab: "inventory", views: [_bv.PageLayout, _vi.Layout] },

  "getting_started":
    url:  "getting_started"
    help: "Welcome to Bixby! Before you can do anything useful, you need to add at least one host. Run the command below on a server to get it into Bixby."

    views:      _vi.GettingStarted
    models:     { hosts: Bixby.model.HostList } # needed for validation

    validate: ->
      if @hosts? && !@hosts.isEmpty()
        @transition "inventory", {hosts: @hosts}
        return false
      return true

  "inventory":
    url:  "inventory"
    help: "A list of servers and related information. Click on a server for more information or on a tag to filter the list."

    views:      _vi.HostTable
    models:     { hosts: Bixby.model.HostList }

    validate: ->
      if !@query && (!@hosts? or @hosts.isEmpty())
        @transition "getting_started", {hosts: @hosts}
        return false
      return true

  "inv_view_host":
    url:  "inventory/hosts/:host_id"
    help: "Detailed host information. Click `Edit` to modify details such as its name and tags."

    views:      _vi.Host
    models:     { host: Bixby.model.Host }

  "inv_search":
    class extends Stark.State
      url: "inventory/search/:query"

      views:      [ _vi.HostTable ]
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
