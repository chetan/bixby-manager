
jQuery ->

  Bixby.app.add_state(
    class InventoryState extends Stark.State

      name: "inventory"
      url:  "inventory"
      tab:  "inventory"

      views:      [ Bixby.view.PageLayout, Bixby.view.inventory.Layout, Bixby.view.inventory.HostTable ]
      no_redraw:  [ Bixby.view.PageLayout, Bixby.view.inventory.Layout ]
      models:     { hosts: Bixby.model.HostList }
  )

  Bixby.app.add_state(
    class extends Stark.State

      name: "inv_view_host"
      url:  "inventory/hosts/:host_id"
      tab:  "inventory"

      views:      [ Bixby.view.PageLayout, Bixby.view.inventory.Layout, Bixby.view.inventory.Host ]
      no_redraw:  [ Bixby.view.PageLayout, Bixby.view.inventory.Layout ]
      models:     { host: Bixby.model.Host }
  )
