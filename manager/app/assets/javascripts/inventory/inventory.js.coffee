
jQuery ->

  Bixby.router.route "inventory", "inventory", ->

    console.log("inventory() route called")

    inventory_layout = new Bixby.view.inventory.Layout
    inventory_layout.render()

    host_table = new Bixby.view.inventory.HostTable( $("div.host_table") )
