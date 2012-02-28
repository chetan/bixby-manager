
namespace "Bixby.view.inventory", (exports, top) ->

  class exports.Layout extends Backbone.View
    el: $("#content")
    template: new Template(Bixby.tmpl.inventory.layout)
    render: ->
      $(@el).html(@template.render(@))
      @

  class exports.HostTable extends Backbone.View
    template: new Template(Bixby.tmpl.inventory.host_table)

    initialize: ->
      _.bindAll @
      @hosts = Bixby.data.Hosts

    render: ->
      $(@el).html(@template.render(@))
      @

