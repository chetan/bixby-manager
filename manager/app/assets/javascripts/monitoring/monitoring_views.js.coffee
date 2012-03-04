
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Layout extends Backbone.View
    el: $("#content")
    template: "monitoring/layout"
    events: {
      "click .add_resource_link": (e) ->
        Bixby.router.navigate( "monitoring/hosts/#{$(e.target).attr("host_id")}/resources/new", {trigger: true} )
    }
