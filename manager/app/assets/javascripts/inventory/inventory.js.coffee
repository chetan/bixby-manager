
jQuery ->

  Bixby.app.add_state(
    class InventoryState extends Stark.State
      name: "inventory" #  canonical name used for state transitions
                        #  e.g., it is referred to in events hash of other states

      url:  "inventory" #  match() pattern [optional]

      views:      [ Bixby.view.PageLayout, Bixby.view.inventory.Layout, Bixby.view.inventory.HostTable ]
      no_redraw:  [ Bixby.view.PageLayout, Bixby.view.inventory.Layout ]
      models:     { hosts: Bixby.model.HostList }

      activate: ->
        @app.trigger("nav:select_tab", "inventory")
  )
