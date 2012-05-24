
namespace 'Bixby.model', (exports, top) ->

  class exports.Agent extends Backbone.Model
  class exports.Command extends Backbone.Model

  class exports.Host extends Backbone.Model
    urlRoot: "/inventory"
    initialize: (params) ->
      if _.isObject(params)
        if params.host_id?
          @id = params.host_id


  class exports.HostList extends Backbone.Collection
    model: exports.Host
    url: "/inventory"

namespace 'Bixby.data', (exports, top) ->
  exports.Hosts = new Bixby.model.HostList
