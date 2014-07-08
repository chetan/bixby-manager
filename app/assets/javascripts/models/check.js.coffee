
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
    args_str: (command, host) ->
      # if a command argument is provided then we get the nice formatted output...
      args = @get("args")
      if ! args
        return ""

      args_array = _.map(args, (val, key) ->
        s = if command
          command.get("options")[key]["name"]
        else
          key
        s += " = "

        if _.contains(["password", "pass", "pw"], key)
          s += "[hidden]"
        else
          s += val

        return s
      )

      if command && host
        s = "Run check from host: "
        s += host.name()
        if (command.location == "remote" || command.location == "any")
           args_array.push s

      if command
        return args_array.join("<br/>")
      else
        return args_array.join(", ")


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
