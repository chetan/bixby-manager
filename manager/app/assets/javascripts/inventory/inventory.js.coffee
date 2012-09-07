
jQuery ->

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

      views:      [ _bv.PageLayout, _vi.Layout, _vi.HostTable ]
      models:     { hosts: Bixby.model.HostList, query: "" }

      load_data: (data) ->
        @query = data.query
        @hosts = new Bixby.model.HostList()
        @hosts.query = @query
        return [ @hosts ]

  )
