
jQuery ->

  Bixby.app.add_state(
    class InventoryState extends Stark.State
      name: "inventory" #  canonical name used for state transitions
                        #  e.g., it is referred to in events hash of other states

      url:  "inventory" #  match() pattern [optional]

      views:      [ Bixby.view.inventory.Layout, Bixby.view.inventory.HostTable ]
      no_redraw:  [ Bixby.view.inventory.Layout ]
      models:     { hosts: Bixby.model.HostList }

      events: {
        mon_view_host: { models: [ Bixby.model.Host ] }
      }

      load_data: ->
        needed = []
        if ! @hosts?
          @hosts = new Bixby.model.HostList()
          needed.push @hosts

        return needed
  )
