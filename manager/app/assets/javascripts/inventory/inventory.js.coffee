
jQuery ->

  Bixby.router.route "inventory", "inventory", ->

    console.log("inventory() route called")

    inventory_layout = new Bixby.view.inventory.Layout
    inventory_layout.render()

    host_table = new Bixby.view.inventory.HostTable
    host_table.setElement($("div.host_table"))
    host_table.render()

    $(".monitoring_host_link").click( ->
      Bixby.router.navigate( "monitoring/hosts/#{$(@).attr("host_id")}", {trigger: true} )
      )

  Bixby.router.route "monitoring/hosts/:host_id", "monitoring_hosts", (host_id) ->
    console.log("monitoring_hosts() route called")
