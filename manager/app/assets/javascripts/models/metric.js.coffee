
namespace 'Bixby.model', (exports, top) ->

  class exports.Metric extends Stark.Model

    initialize: (data) ->
      @extract_param(data, "host")

    url: ->
      host_id = @host_id || @get("host_id")
      id = @id || @get("id")
      s = "/monitoring/hosts/#{host_id}/metrics/#{id}?"
      if @get("start") and @get("end")
        s += "&start=#{@get("start")}&end=#{@get("end")}"
      return s

    # get only the metric attributes (the actual data elements)
    # { key, tags, vals: [ {time, val}, ... ]}
    metrics: ->
      metrics = []
      _.each @attributes, (v, k) ->
        if _.isObject(v)
          metrics.push(v)

      return metrics




  class exports.MetricList extends Stark.Collection
    model: exports.Metric
    url: -> "/monitoring/hosts/#{@host_id}/metrics"

    initialize: (data) ->
      @extract_param(data, "host")
