
namespace "Bixby.view.inventory", (exports, top) ->

  class exports.Layout extends Stark.View
    el: $("#content")

    initialize: ->
      _.bindAll @
      @template = new Template(JST["inventory/layout"])

    render: ->
      $(@el).html(@template.render(@))
      @

  class exports.HostTable extends Stark.View

    el: "div.inventory_content"

    events: {
      "click .monitoring_host_link": (e) ->
        Bixby.router.navigate( "monitoring/hosts/#{$(e.target).attr("host_id")}", {trigger: true} )
    }

    initialize: ->
      _.bindAll @
      @template = new Template(JST["inventory/host_table"])

    render: ->
      $(@el).html(@template.render(@))
      @
