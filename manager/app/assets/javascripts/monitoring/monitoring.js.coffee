jQuery ->

  Bixby.router.route "monitoring/hosts/:host_id", "monitoring_hosts", (host_id) ->

    console.log("monitoring() route called")

    $("#content").ajaxStop ->
      mon_layout = new Bixby.view.monitoring.Layout(host, resources)
      mon_layout.render()

      $(".add_resource_link").click( ->
        Bixby.router.navigate( "monitoring/hosts/#{$(@).attr("host_id")}/resources/new", {trigger: true} )
        )

    host = new Bixby.model.Host({ id: host_id })
    host.fetch()
    resources = new Bixby.model.ResourceList(host_id)
    resources.fetch()

  Bixby.router.route "monitoring/hosts/:host_id/resources/new", "monitoring_hosts_resources_new", (host_id) ->
    console.log("monitoring_hosts_resources_new() route called")


