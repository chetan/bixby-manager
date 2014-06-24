
class Bixby.Runbooks extends Stark.View

  el: "#content"
  template: "runbooks/runbooks"

  events:
    "click button#run": (e) ->
      hosts = @$("select#hosts").val()
      command = @commands.get @$("select#command").val()

      if hosts.length <= 0 || !command
        @log "no host or command selected!"
        return

      command = command.clone()
      args    = @$("#args").val()
      stdin   = @$("#stdin").val()

      command.run hosts, args, stdin, (res) =>
        _.each res, (r, host_id) =>
          host = @hosts.get(host_id)
          @partial B.CommandResponse, {host: host, response: r}, "div.results"

    "click label.args": (e) ->
      @$("textarea#args").toggle().focus()

    "click label.stdin": (e) ->
      @$("textarea#stdin").toggle().focus()

  after_render: ->
    @$("select#command").select2({
      allowClear: true
      matcher: (term, text, opt) ->
        # use default matcher to evaluate the option as well its option group label
        optgroup = $(opt).parent().attr("label")
        $.prototype.select2.defaults.matcher(term, text) ||
          $.prototype.select2.defaults.matcher(term, optgroup)
      })

    @$("select#hosts").select2({
      allowClear: true
      matcher: (term, text, opt) ->
        # use default matcher to evaluate the option as well its option group label
        optgroup = $(opt).parent().attr("label")
        $.prototype.select2.defaults.matcher(term, text) ||
          $.prototype.select2.defaults.matcher(term, optgroup)
      })
