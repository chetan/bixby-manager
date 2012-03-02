
jQuery ->
  console.log "firing inventory ready"

  class InventoryState extends Stark.State
    name: "inventory" #  canonical name used for state transitions
                      #  e.g., it is referred to in events hash of other states

    url:  "inventory" #  match() pattern

    views:      [ Bixby.view.inventory.Layout, Bixby.view.inventory.HostTable ]
    no_redraw:  [ Bixby.view.inventory.Layout ]
    models:     { hosts: Bixby.model.HostList }

    events: {
      mon_view_host: { models: [ Bixby.model.Host ] }
    }

  Bixby.app.add_state(InventoryState)


  # Bixby.router.route "inventory", "inventory", ->

  #   console.log("inventory() route called")

  #   inventory_layout = new Bixby.view.inventory.Layout
  #   inventory_layout.render()

  #   host_table = new Bixby.view.inventory.HostTable
