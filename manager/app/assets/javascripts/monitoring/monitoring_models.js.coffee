
namespace 'Bixby.model', (exports, top) ->

  # class exports.Resource extends Stark.Model
  #   url: -> "/monitoring/hosts/#{@get("host_id")}/resources/#{@get("id")}"

  # class exports.ResourceList extends Stark.Collection
  #   model: exports.Resource
  #   url: -> "/monitoring/hosts/#{@host_id}/resources"
  #   initialize: (host_id) -> @host_id = host_id

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


  # MonitoringCommand
  class exports.MonitoringCommand extends Stark.Model
    urlRoot: "/monitoring/commands"
    command: ->
      cmd = @get("command")
      cmd.replace(/monitoring\//, "")
    has_options: ->
      opts = @get("options")
      if ! opts? || _.keys(opts).length == 0
        return false

      return true

  class exports.MonitoringCommandList extends Stark.Collection
    model: exports.MonitoringCommand
    url: "/monitoring/commands"

  # MonitoringCommandOpts
  class exports.MonitoringCommandOpts extends exports.MonitoringCommand
    url: -> "/monitoring/hosts/#{@host.id}/command/#{@id}/opts"

  # Check
  class exports.Check extends Stark.Model
    url: ->
      s = "/monitoring/hosts/#{@host_id || @host.id}/checks" # id is appended if avail for update
      if @metric_id?
        s += "?metric_id=" + @metric_id
      return s

    initialize: (data) ->
      @extract_param(data, "host")

  class exports.CheckList extends Stark.Collection
    model: exports.Check
    url: -> "/monitoring/hosts/#{@host_id || @host.id}/checks"

    initialize: (data) ->
      @extract_param(data, "host")
