
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

    events: {
      "click .monitoring_host_link": (e) ->
        Bixby.router.navigate( "monitoring/hosts/#{$(e.target).attr("host_id")}", {trigger: true} )
    }

    initialize: (el) ->
      _.bindAll @
      @setElement(el)
      @template = new Template(JST["inventory/host_table"])
      @hosts = Bixby.data.Hosts
      @render()

    render: ->
      $(@el).html(@template.render(@))
      @
