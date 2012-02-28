
namespace 'Bixby.model', (exports, top) ->

  class exports.Host extends Backbone.Model

    # not sure I need defaults at all...
    # defaults:
    #   id: null
    #   org_id: null
    #   ip: null
    #   hostname: ""
    #   alias: ""
    #   desc: ""

  class exports.HostList extends Backbone.Collection
    model: Bixby.model.Host
    url: "/inventory"

namespace 'Bixby.data', (exports, top) ->
  exports.Hosts = new Bixby.model.HostList
