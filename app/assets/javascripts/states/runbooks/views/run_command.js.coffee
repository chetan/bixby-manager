
class Bixby.RunCommand extends Stark.View

  el: "#content"
  template: "runbooks/run_command"

  ui:
    actions: "div.actions"
    run: "button#run"
    schedule:
      btn: "button#schedule"
      div: "div.schedule"
    spinner: "i.spinner"
    results: "div.results"
    args:  "div.args textarea"
    stdin: "div.stdin textarea"
    env:   "div.env textarea"
    create_schedule: "button#create_schedule"
    next_schedule: "div.next_schedule"

  events:
    "change select#command": (e) ->
      command = @commands.get @$("select#command").val()
      @partial("runbooks/_command_detail", {command: command}, "div.detail")
      @$("div.detail").show()

    "click run": (e) ->
      @run_command()

    "click schedule.btn": (e) ->
      @with_inputs(@schedule_command)

    "click button.toggle": (e) ->
      id = @$(e.target).attr("id")
      _.toggleClass(e.target, "active")
      @$("div.form-group.#{id}").toggle()
      @$("textarea##{id}_input").focus()

    "click div.radio input.once": ->
      @$("div.natural").show()
      @$("div.cron").hide()

    "click div.radio input.cron": ->
      @$("div.cron").show()
      @$("div.natural").hide()

    "keyup input.cron": _.debounceR 250, (e) ->
      _.unique_val e.target, (val) => @validate_schedule("cron", val)

    "keyup input.natural": _.debounceR 250, (e) ->
      _.unique_val e.target, (val) => @validate_schedule("natural", val)

  validate_schedule: (type, val) ->
    div = "div.valid.#{type}"
    if !(val && val.length)
      # clear the validation
      @ui.next_schedule.hide()
      return _.toggle_valid_input(div, null, null, true)

    Bixby.model.ScheduledCommand.validate type, val, (res) =>
      if res == false
        _.fail(div)
        @ui.create_schedule.addClass("disabled")
        @ui.next_schedule.hide()
      else
        [time, time_rel] = res
        _.pass(div)
        @ui.create_schedule.removeClass("disabled")
        text = if type == "cron"
          "Next run time would be "
        else
          "Command would run at "
        text += moment(time).format("L HH:mm:ss")
        text += " (#{time_rel} from now)"
        @ui.next_schedule.text(text).show()


  # Common input handling for run/schedule below
  with_inputs: (cmd) ->
    hosts = @$("select#hosts").val()
    command = @commands.get @$("select#command").val()

    if !hosts || hosts.length <= 0 || !command
      @log "no host or command selected!"
      return

    args  = @ui.args.filter(":visible").val()
    stdin = @ui.stdin.filter(":visible").val()
    env   = @ui.env.filter(":visible").val()

    cmd.call(@, hosts, command.clone(), args, stdin, env)

  schedule_command: (hosts, command, args, stdin, env) ->
    @ui.actions.hide()
    @ui.results.hide()
    @ui.schedule.div.show()

  # Run the given command on a set of hosts
  run_command: (hosts, command, args, stdin, env) ->
    @ui.run.addClass("disabled")
    @ui.schedule.btn.addClass("disabled")
    @ui.spinner.show().addClass("fa-spin")
    @ui.results.html("")
    command.run hosts, args, stdin, env, (res) =>
      _.each res, (command_log, host_id) =>
        clazz = "result#{host_id}"
        @ui.results.append("<div class='#{clazz}'></div>")
        command_log.host ||= @hosts.get(host_id).name() # fix the host name, only for invalid hosts
        @partial B.CommandResponse, {command_log: command_log}, "div.#{clazz}"
      @ui.spinner.hide().removeClass("fa-spin")
      @ui.run.removeClass("disabled")
      @ui.schedule.btn.removeClass("disabled")

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
