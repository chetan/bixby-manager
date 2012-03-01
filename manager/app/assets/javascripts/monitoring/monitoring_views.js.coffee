
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Layout extends Backbone.View

    el: $("#content")

    events: {
      "click .add_resource_link": (e) ->
        Bixby.router.navigate( "monitoring/hosts/#{$(e.target).attr("host_id")}/resources/new", {trigger: true} )
    }

    initialize: (host, resources) ->
      _.bindAll @
      @template = new Template(JST["monitoring/layout"])
      @host = host
      @resources = resources

    render: ->
      $(@el).html(@template.render(@))
      @
