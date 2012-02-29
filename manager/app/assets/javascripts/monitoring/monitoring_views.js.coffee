
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Layout extends Backbone.View
    el: $("#content")

    initialize: (host, resources) ->
      _.bindAll @
      @template = new Template(JST["monitoring/layout"])
      @host = host
      @resources = resources

    render: ->
      $(@el).html(@template.render(@))
      @
