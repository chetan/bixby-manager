
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Monitoring extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/home"
    events: {
    }

    links: {
      ".create_schedule_link": [ "mon_oncalls_new" ]

    }

    render: ->
      super()
