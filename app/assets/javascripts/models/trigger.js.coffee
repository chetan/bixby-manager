
namespace 'Bixby.model', (exports, top) ->

  class exports.Trigger extends Stark.Model

    url: ->
      "/monitoring/hosts/#{@host_id || @host.id}/triggers" # id is appended if avail for update

    get_metric: (view) ->
      return @metric if @metric?

      if @get("metric")?
        @metric = new Bixby.model.Metric(@get("metric"))
        return @metric

      @metric = new Bixby.model.Metric({ id: @get("metric_id") })
      @metric.bind_view(view)
      @metric.fetch()
      @metric

    severity: ->
      switch @get("severity")
        when 2 then "Warning"
        when 3 then "Critical"

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
    url: -> "/monitoring/hosts/#{@host_id || @host.id}/triggers"

    initialize: (data) ->
      @extract_param(data, "host")
