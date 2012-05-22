
namespace 'Bixby.model', (exports, top) ->

  # class exports.Resource extends Backbone.Model
  #   url: -> "/monitoring/hosts/#{@get("host_id")}/resources/#{@get("id")}"

  # class exports.ResourceList extends Backbone.Collection
  #   model: exports.Resource
  #   url: -> "/monitoring/hosts/#{@host_id}/resources"
  #   initialize: (host_id) -> @host_id = host_id

  class exports.Metric extends Backbone.Model

    initialize: (host_id) -> @host_id = host_id

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

  class exports.MetricList extends Backbone.Collection
    model: exports.Metric
    url: -> "/monitoring/hosts/#{@host_id}/metrics"
    initialize: (host_id) -> @host_id = host_id


  # MonitoringCommand
  class exports.MonitoringCommand extends Backbone.Model
    urlRoot: "/monitoring/commands"
    command: ->
      cmd = @get("command")
      cmd.replace(/monitoring\//, "")
    has_options: ->
      opts = @get("options")
      if ! opts? || _.keys(opts).length == 0
        return false

      return true

  class exports.MonitoringCommandList extends Backbone.Collection
    model: exports.MonitoringCommand
    url: "/monitoring/commands"

  # MonitoringCommandOpts
  class exports.MonitoringCommandOpts extends exports.MonitoringCommand
    url: -> "/monitoring/hosts/#{@host.id}/command/#{@id}/opts"

  # Check
  class exports.Check extends Backbone.Model
    url: ->
      s = "/monitoring/hosts/#{@host_id}/checks" # id is appended if avail for update
      if @metric_id?
        s += "?metric_id=" + @metric_id

    initialize: (host_id) -> @host_id = host_id

  class exports.CheckList extends Backbone.Collection
    model: exports.Check
    url: -> "/monitoring/hosts/#{@host_id}/checks"
    initialize: (host_id) -> @host_id = host_id
