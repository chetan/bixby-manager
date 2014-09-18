
class Bixby.RunCommand extends Stark.View

  el: "#content"
  template: "runbooks/run_command"

  ui:
    run: "button#run"
    spinner: "i.spinner"

  events:
    "change select#command": (e) ->
      command = @commands.get @$("select#command").val()
      @partial("runbooks/_command_detail", {command: command}, "div.detail")
      @$("div.detail").show()

    "click run": (e) ->
      hosts = @$("select#hosts").val()
      command = @commands.get @$("select#command").val()

      if hosts.length <= 0 || !command
        @log "no host or command selected!"
        return

      command = command.clone()
      args    = @$("div.args textarea").filter(":visible").val()
      stdin   = @$("div.stdin textarea").filter(":visible").val()
      env     = @$("div.env textarea").filter(":visible").val()

      @ui.run.addClass("disabled")
      @ui.spinner.show().addClass("fa-spin")
      @$("div.results").html("")
      command.run hosts, args, stdin, env, (res) =>
        _.each res, (r, host_id) =>
          clazz = "result#{host_id}"
          @$("div.results").append("<div class='#{clazz}'></div>")
          host = @hosts.get(host_id)
          @partial B.CommandResponse, {host: host, response: r}, "div.#{clazz}"
        @ui.spinner.hide().removeClass("fa-spin")
        @ui.run.removeClass("disabled")

    "click button.toggle": (e) ->
      id = @$(e.target).attr("id")
      _.toggleClass(e.target, "active")
      @$("div.form-group.#{id}").toggle()
      @$("textarea##{id}_input").focus()

  # Return tags in a sorted, space-separated format
  # ex: "#bar #foo"
  #
  # @param [Host] h
  host_tags: (h) ->
    tags = h.tags()
    return "" if tags.length == 0
    tags = _.map(tags, (t) -> "##{t}")
    return tags.join(" ")

  after_render: ->
    @$("select#command").select2
      allowClear: true
      matcher: (term, text, opt) ->
        # use default matcher to evaluate the option as well its option group label
        optgroup = $(opt).parent().attr("label")
        m = $.prototype.select2.defaults.matcher
        m(term, text) || m(term, optgroup)

    @$("select#hosts").select2
      allowClear: true
      formatResult: (obj, container, query, escapeMarkup) =>
        # display tags in the dropdown, if available
        host = @hosts.get($(obj.element).val())
        markup = []
        Select2.util.markMatch(obj.text, query.term, markup, (s) -> s)
        text = markup.join("")
        if tags = @host_tags(host)
          markup = []
          Select2.util.markMatch(tags, query.term, markup, (s) -> s)
          text += " <span class='tags'>" + markup.join("") + "</span>"
        return text

      matcher: (term, text, opt) =>
        # match against host name, tags
        m = $.prototype.select2.defaults.matcher
        host = @hosts.get(opt.val())
        tags = host.tags()
        if term[0] == "#"
          term = term.substr(1)
        m(term, text) || m(term, host.get("desc")) || _.include(tags, term) || _.find(tags, (t) -> t.indexOf(term) >= 0)
