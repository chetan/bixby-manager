
namespace 'Bixby.model', (exports, top) ->



  class exports.Check extends Stark.Model

    url: ->
      s = "/monitoring/hosts/#{@host_id || @host.id}/checks" # id is appended if avail for update
      if @metric_id?
        s += "?metric_id=" + @metric_id
      return s

    initialize: (data) ->
      @extract_param(data, "host")
      @extract_param(data, "metric")



  class exports.CheckList extends Stark.Collection
    model: exports.Check
    url: -> "/monitoring/hosts/#{@host_id || @host.id}/checks"

    initialize: (data) ->
      @extract_param(data, "host")
