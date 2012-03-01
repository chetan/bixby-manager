
jQuery ->

  Bixby.router.route "monitoring/hosts/:host_id", "monitoring_hosts", (host_id) ->

    console.log("monitoring() route called")

    host = new Bixby.model.Host({ id: host_id })
    resources = new Bixby.model.ResourceList(host_id)

    Backbone.multi_fetch [host, resources],
      (err, results) ->
        mon_layout = new Bixby.view.monitoring.Layout(host, resources)
        mon_layout.render()


  Bixby.router.route "monitoring/hosts/:host_id/resources/new", "monitoring_hosts_resources_new", (host_id) ->
    console.log("monitoring_hosts_resources_new() route called")

