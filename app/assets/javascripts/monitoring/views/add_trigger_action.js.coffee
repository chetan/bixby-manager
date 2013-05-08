namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.AddTriggerAction extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/add_trigger_action"
    events: {
      # create trigger
      "click #submit_action": (e) ->
        action = new Bixby.model.Action {
          host_id: @host.id
          trigger_id: @trigger.id
          action_type: $("#action_type").val()
          target_id: $("#oncall").val()
          args: null # TODO when implementing exec
        }

        view = @
        Backbone.multi_save action, (err, results) ->
          view.transition "mon_view_host", { host: view.host }
    }
