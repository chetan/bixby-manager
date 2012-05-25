
namespace 'Bixby.model', (exports, top) ->

  class exports.Host extends Stark.Model
    urlRoot: "/inventory"

    initialize: (data) ->
      @extract_param(data, "host")
      if @host_id?
        @id = @host_id

  class exports.HostList extends Stark.Collection
    model: exports.Host
    url: "/inventory"
