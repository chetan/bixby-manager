
namespace 'Bixby.model', (exports, top) ->

  class exports.Trigger extends Stark.Model

    urlRoot: ->
      "/rest/hosts/#{@host_id || @host.id}/triggers"

    params: [ "host" ]

    # Hacky - pass the view in so we can bind it for an update
    # after loading the metric async (if necessary)
    get_metric_key: (view) ->
      return @metric_key if @metric_key?
      return @metric.get("key") if @metric?

      if @get("metric")?
        @metric = new Bixby.model.Metric(@get("metric"))
        return @metric.get("key")

      @metric = new Bixby.model.Metric({ id: @get("metric_id") })
      @metric.bind_view(view)
      @metric.fetch()
      return ""

    severity: ->
      switch @get("severity")
        when 2, "warning" then "Warning"
        when 3, "critical" then "Critical"

    threshold: ->
      t = @signHtml() + " " + @get("threshold")

    signHtml: ->
      switch @get("sign")
        when "eq" then "="
        when "ne" then "!="
        when "le" then "&lt;="
        when "lt" then "&lt;"
        when "ge" then "&gt;="
        when "gt" then "&gt;"


  class exports.TriggerList extends Stark.Collection
    model: exports.Trigger
    url: -> "/rest/hosts/#{@host_id || @host.id}/triggers"
    params: [ "host" ]
