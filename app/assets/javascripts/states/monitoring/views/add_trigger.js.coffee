namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.AddTrigger extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/add_trigger"
    events: {

      # update Sign in button text
      "click ul.trigger_sign a": (e) ->
        e.preventDefault()
        $("button.trigger_sign").text $(e.target).text()
        $("input.sign").val $(e.target).attr("value")

      # disable auto-toggling of statuses
      "click input.trigger_status": (e) ->
        @no_toggle_status = true

      # toggle status checkboxes when selecting severity
      "change #severity": (e) ->
        if @no_toggle_status? && @no_toggle_status
          return # don't flip bits if user has manually made selections

        warn = [ "WARNING", "UNKNOWN", "TIMEOUT" ]
        if $(e.target).val() == "warning"
          # select warning defaults
          _.each warn, (s) ->
            $("input.trigger_status[value='#{s}']").prop("checked", true)
          $("input.trigger_status[value='CRITICAL']").prop("checked", false)

        else
          # select critical defaults
          _.each warn, (s) ->
            $("input.trigger_status[value='#{s}']").prop("checked", false)
          $("input.trigger_status[value='CRITICAL']").prop("checked", true)

      # create trigger
      "click #submit_trigger": (e) ->
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
        trigger.metric_key = $("#metric option").filter(":selected").text()

        @transition "mon_hosts_actions_new", { host: host, trigger: trigger, users: @state.users, on_calls: @state.on_calls }

    } # events
