
namespace 'Bixby.model', (exports, top) ->

  class exports.Check extends Stark.Model

    urlRoot: ->
      s = "/rest/hosts/#{@host_id || @host.id}/checks"

    params: [ "host", "metric", { name: "check", set_id: true } ]

    url: ->
      s = super()
      if @metric_id?
        s += "?metric_id=" + @metric_id
      return s

    has_args: ->
      @get("args")? && !_.isEmpty(@get("args"))

    # Return args as a comma-separated string of "key = value" pairs
    args_str: ->
      args = @get("args")
      if ! args
        return ""

      _.map(args, (val, key) ->
        s = key + " = "
        if _.contains(["password", "pass", "pw"], key)
          s += "[hidden]"
        else
          s += val
        return s
      ).join(", ")

    # Get list of metrics of for this check (same check id)
    filter_metrics: (metrics) ->
      c = @
      _.sortBy(
        metrics.filter((m) -> m.get("check_id") == c.id),
        "id")


  class exports.CheckList extends Stark.Collection
    model: exports.Check
    url: -> "/rest/hosts/#{@host_id || @host.id}/checks"
    params: [ "host" ]

    comparator: (check) ->
      check.get("name")
