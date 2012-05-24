
namespace 'Bixby.model', (exports, top) ->

  class exports.Agent extends Stark.Model
  class exports.Command extends Stark.Model

  class exports.Host extends Stark.Model
    urlRoot: "/inventory"

    initialize: (data) ->
      @extract_param(data, "host")

  class exports.HostList extends Stark.Collection
    model: exports.Host
    url: "/inventory"

namespace 'Bixby.data', (exports, top) ->
  exports.Hosts = new Bixby.model.HostList
