
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
