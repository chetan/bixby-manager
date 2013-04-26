namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.AddTrigger extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/add_trigger"
    events: {
      "click ul.trigger_sign a": (e) ->
        e.preventDefault()
        $("button.trigger_sign").text $(e.target).text()
        $("input.sign").val $(e.target).attr("value")

      "click #submit_trigger": (e) ->
        # create trigger obj
        trigger = new Bixby.model.Trigger
        trigger.host = host = @host
        trigger.set {
          check_id:   $("#metric option").filter(":selected").attr("check_id")
          metric_id:  $("#metric").val()
          severity:   $("#severity").val()
          sign:       $("#sign").val()
          threshold:  $("#threshold").val()
          status:     _.map $("input.trigger_status:checked"), (el) -> $(el).val()
        }

        view = @
        Backbone.multi_save trigger, (err, results) ->
          view.transition "mon_view_host", { host: host }

    }
