
namespace 'Bixby.model', (exports, top) ->

  class exports.Resource extends Backbone.Model
    url: ->
      "/monitoring/hosts/" + @get("host_id") + "/resources/" + @get("id")

  class exports.ResourceList extends Backbone.Collection
    model: Bixby.model.Resource
    url: ->
      "/monitoring/hosts/#{@host_id}/resources"
    initialize: (host_id) ->
      @host_id = host_id

  class exports.Check extends Backbone.Model
    url: ->
      "/monitoring/hosts/" + @get("host_id") + "/checks/" + @get("id")

  class exports.CheckList extends Backbone.Collection
    model: Bixby.model.Check
    url: ->
      "/monitoring/hosts/#{@host_id}/checks"
    initialize: (host_id) ->
      @host_id = host_id
