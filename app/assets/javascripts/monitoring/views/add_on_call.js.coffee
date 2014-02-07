
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.AddOnCall extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/add_on_call"
    events: {
      "click #submit": (e) ->
        oncall = new Bixby.model.OnCall()
        oncall.set {
          name:             @$("#name").val()
          rotation_period:  @$("#rotation_period").val()
          handoff_day:      @$("#handoff_day").val()
          handoff_hour:     @$("#handoff_hour").val()
          handoff_min:      @$("#handoff_min").val()
        }
        oncall.set_users @$("#users").val()

        view = @
        Backbone.multi_save oncall, (err, results) ->
          view.transition "monitoring", { host: view.host }
    }

    after_render: ->
      @$("select#users").select2()
