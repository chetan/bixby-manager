
#= require_tree "./views"

_bv = Bixby.view
_vi = Bixby.view.inventory

Bixby.app.add_state(
  class extends Stark.State

    name: "inventory"
    url:  "inventory"
    tab:  "inventory"

    views:      [ _bv.PageLayout, _vi.Layout, _vi.HostTable ]
    models:     { hosts: Bixby.model.HostList }
)

Bixby.app.add_state(
  class extends Stark.State

    name: "inv_view_host"
    url:  "inventory/hosts/:host_id"
    tab:  "inventory"

    views:      [ _bv.PageLayout, _vi.Layout, _vi.Host ]
    models:     { host: Bixby.model.Host }
)

Bixby.app.add_state(
  class extends Stark.State

    name: "inv_search"
    url: "inventory/search/:query"
    tab: "inventory"

    views:      [ _bv.PageLayout, _vi.Layout, _vi.HostSearchHeader, _vi.HostTable ]
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

)
