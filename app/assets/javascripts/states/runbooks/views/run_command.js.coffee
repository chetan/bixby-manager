
class Bixby.RunCommand extends Stark.View

  el: "#content"
  template: "runbooks/run_command"

  ui:
    actions: "div.actions"
    run: "button#run"
    spinner: "i.spinner"
    results: "div.results"
    args:  "div.args textarea"
    stdin: "div.stdin textarea"
    env:   "div.env textarea"
    schedule:
      btn: "button#schedule"
      div: "div.schedule"
    configure_email: "button#configure_email"
    next_schedule: "div.next_schedule"
    calendar: "button.calendar"
    cron:
      div: "div.cron"
      radio: "div.radio input.cron"
      text: "div.cron input.cron"
    natural:
      div: "div.natural"
      radio: "div.radio input.natural"
      text: "div.natural input.natural"

    tab:
      1: "div.select_command"
      2: "div.schedule_command"
    collapse:
      1: "button.collapse_select_command"
      2: "button.collapse_schedule_command"
    command_detail: "div.detail"

  events:
    "change select#command": (e) ->
      command = @commands.get @$("select#command").val()
      @partial("runbooks/_command_detail", {command: command}, "div.detail")
      @ui.command_detail.show()

    "click run": (e) ->
      @with_inputs(@run_command)

    "click schedule.btn": (e) ->
      @with_inputs(@schedule_command)

    "click button.toggle": (e) ->
      id = @$(e.target).attr("id")
      _.toggleClass(e.target, "active")
      @$("div.form-group.#{id}").toggle()
      @$("textarea##{id}_input").focus()

    "click natural.radio": ->
      @ui.natural.div.show()
      @ui.cron.div.hide()
      @ui.next_schedule.hide()
      @validate_schedule("natural", @ui.natural.text.val())

    "click cron.radio": ->
      @ui.cron.div.show()
      @ui.natural.div.hide()
      @ui.next_schedule.hide()
      @validate_schedule("cron", @ui.cron.text.val())

    "keyup cron.text": _.debounceR 250, (e) ->
      _.unique_val e.target, (val) => @validate_schedule("cron", val)

    "keyup natural.text": _.debounceR 250, (e) ->
      _.unique_val e.target, (val) => @validate_schedule("natural", val)

    "click calendar": ->
      @ui.calendar.datepicker("show")

    "click h4.tab1, collapse.1": ->
      if @ui.collapse[1].filter(":visible").length
        @select_tab(1)

    "click h4.tab2, collapse.2": ->
      @select_tab(2)

  validate_schedule: (type, val) ->
    div = "div.valid.#{type}"
    if !(val && val.length)
      # clear the validation
      @ui.configure_email.addClass("disabled")
      @ui.next_schedule.hide()
      return _.toggle_valid_input(div, null, null, true)

    Bixby.model.ScheduledCommand.validate type, val, (res) =>
      @toggle_schedule_status(div, res != false)
      if res != false
        [time, time_rel] = res
        @set_next_schedule(type, time, time_rel)

  set_next_schedule: (type, time, time_rel) ->
    text = if type == "cron"
      "Next run time would be "
    else
      "Command would run at "
    text += moment(time).format("L HH:mm:ss")
    text += " (#{time_rel} from now)" if time_rel
    @ui.next_schedule.text(text).show()

  toggle_schedule_status: (div, pass) ->
    if pass
      _.pass(div)
      @ui.configure_email.removeClass("disabled")
    else
      _.fail(div)
      @ui.configure_email.addClass("disabled")
      @ui.next_schedule.hide()

  validate_datepicker: (date, time) ->
    date ?= new Date()
    date = moment(date)

    if !time
      @toggle_schedule_status("div.valid.natural", false)
      @ui.natural.text.val("time is required")
      return

    Bixby.model.ScheduledCommand.validate "natural", time, true, (res) =>
      @toggle_schedule_status("div.valid.natural", res != false)
      if res == false
        @ui.natural.text.val("invalid time: " + time)
      else
        # combine date & time
        time = moment(res[0])
        date = moment(new Date(date.year(), date.month(), date.date(), time.hours(), time.minutes(), time.seconds()))
        if (new Date() - date._d) > 0
          @toggle_schedule_status("div.valid.natural", false)
          @ui.natural.text.val("date/time is in the past")
          return
        @set_next_schedule("natural", date)
        @ui.natural.text.val(date.format("L HH:mm:ss"))

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

  select_tab: (tab) ->
    _.each [1..2], (i) =>
      t = @ui.tab[i]
      c = @ui.collapse[i]
      if i == tab
        t.collapse("show")
        c.hide()
      else
        t.collapse("hide")
        c.show()
    @ui.command_detail.toggle(tab == 1)

  schedule_command: (hosts, command, args, stdin, env) ->
    @ui.actions.hide()
    @ui.results.hide()
    @ui.schedule.div.show()
    @select_tab(2)

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
    _.each [1..2], (i) => @ui.tab[i].collapse()

    @ui.calendar.datepicker(
      keyboardNavigation: true
      todayHighlight: true
      startDate: new Date()
      ).on "hide", (e) =>
        @validate_datepicker(e.date, e.time)

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
