
jQuery ->

  Bixby.router.route "inventory", "inventory", ->

    console.log("inventory() route called")

    inventory_layout = new Bixby.view.inventory.Layout
    inventory_layout.render()

    host_table = new Bixby.view.inventory.HostTable( $("div.host_table") )

    $(".monitoring_host_link").click( ->
      Bixby.router.navigate( "monitoring/hosts/#{$(@).attr("host_id")}", {trigger: true} )
      )
