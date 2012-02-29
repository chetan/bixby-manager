
namespace "Bixby.view.inventory", (exports, top) ->

  class exports.Layout extends Backbone.View
    el: $("#content")

    initialize: ->
      _.bindAll @
      @template = new Template(JST["inventory/layout"])

    render: ->
      $(@el).html(@template.render(@))
      @

  class exports.HostTable extends Backbone.View

    initialize: (el) ->
      _.bindAll @
      @el = el
      @template = new Template(JST["inventory/host_table"])
      @hosts = Bixby.data.Hosts
      @render()

    render: ->
      $(@el).html(@template.render(@))
      @

