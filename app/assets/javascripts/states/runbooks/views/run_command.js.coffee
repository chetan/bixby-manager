
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
    configure_email:
      btn: "button#configure_email"
      div: "div.configure_email"
      select: "div.select_emails"
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
      3: "div.configure_email"
    collapse:
      1: "button.collapse_select_command"
      2: "button.collapse_schedule_command"
      3: "button.collapse_configure_email"
    command_detail: "div.detail"
    status: "input.status"
    create_schedule: "button#create_schedule"

  events:
    "change select#command": (e) ->
      if command = @selected_command()
        @partial("runbooks/_command_detail", {command: command}, "div.detail")
        @ui.command_detail.show()
      else
        @ui.command_detail.html("").hide()
      @enable_actions()

    "change select#hosts": (e) ->
      @enable_actions()

    "click run": (e) ->
      @with_inputs(@run_command)

    "click schedule.btn": (e) ->
      @ui.actions.hide()
      @ui.results.hide()
      @ui.schedule.div.show()
      @select_tab(2)

    "click configure_email.btn": (e) ->
      @ui.configure_email.btn.show()
      @ui.configure_email.div.show()
      @select_tab(3)

    "click create_schedule": ->
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
      @ui.natural.text.putCursorAtEnd()

    "click cron.radio": ->
      @ui.cron.div.show()
      @ui.natural.div.hide()
      @ui.next_schedule.hide()
      @validate_schedule("cron", @ui.cron.text.val())
      @ui.cron.text.putCursorAtEnd()

    "keyup cron.text": _.debounceR 250, (e) ->
      _.unique_val e.target, (val) => @validate_schedule("cron", val)

    "datepicker.change natural.text": (e, valid, date, date_rel) ->
      @toggle_schedule_status("div.valid.natural", valid)
      if valid
        @set_next_schedule("natural", date, date_rel)
      else
        @ui.configure_email.btn.addClass("disabled")
        @ui.next_schedule.hide()

    "click h4.tab1, collapse.1": ->
      if @ui.collapse[1].filter(":visible").length
        @select_tab(1)

    "click h4.tab2, collapse.2": ->
      @select_tab(2)

    "click h4.tab3, collapse.3": ->
      @select_tab(3)

    "change status": ->
      # if either of the status checkboxes are checked, show the user selection form
      checks = @ui.status.filter(":checked")
      @ui.configure_email.select.toggle(checks && checks.length > 0)

  validate_schedule: (type, val) ->
    div = "div.valid.#{type}"
    if !(val && val.length)
      # clear the validation
      @ui.configure_email.btn.addClass("disabled")
      @ui.next_schedule.hide()
      return _.clear_valid_input(div)

    Bixby.model.ScheduledCommand.validate type, val, (res) =>
      @toggle_schedule_status(div, res != false)
      if res != false
        [time, time_rel] = res
        @set_next_schedule(type, time, time_rel)

  set_next_schedule: (type, time, time_rel) ->
    text = if type == "cron"
      @ui.natural.text.data("date", null)
      "Next run time would be "
    else
      @ui.natural.text.data("date", time)
      "Command would run at "
    text += moment(time).format("L HH:mm:ss")
    text += " (#{time_rel} from now)" if time_rel
    @ui.next_schedule.text(text).show()

  toggle_schedule_status: (div, pass) ->
    if pass
      _.pass(div)
      @ui.configure_email.btn.removeClass("disabled")
    else
      _.fail(div)
      @ui.configure_email.btn.addClass("disabled")
      @ui.next_schedule.hide()

  # Enable the 'run' and 'schedule' buttons if checks pass
  enable_actions: ->
    enable = !(@selected_command() && @selected_hosts())
    @ui.run.toggleClass("disabled", enable)
    @ui.schedule.btn.toggleClass("disabled", enable)

  # Get the selected Command model
  #
  # @return [Command]
  selected_command: ->
    @commands.get @$("select#command").val()

  # Get the list of selected host ids
  #
  # @return [Array<String>]
  selected_hosts: ->
    hosts = @$("select#hosts").val()
    if !hosts || hosts.length <= 0
      return null
    return hosts

  # Common input handling for run/schedule below
  with_inputs: (fn) ->
    hosts = @selected_hosts()
    command = @selected_command()

    if !hosts || hosts.length <= 0 || !command
      @log "no host or command selected!"
      return

    get_val = (sel) =>
      # the parent div (tab) may be collapsed but we only care if this el was toggled into view
      @$(sel).filter(-> $(@).css("display") == "block").find("textarea").val()

    args  = get_val("div.args")
    stdin = get_val("div.stdin")
    env   = Bixby.model.Command.parse_env(get_val("div.env"))

    fn.call(@, hosts, command.clone(), args, stdin, env)

  select_tab: (tab) ->
    _.each [1..3], (i) =>
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
    alert_users = @$("select#email_to_users").val() || []
    if _.val(@$("input.email_to_me"))
      alert_users.push(@current_user.id)

    sc = new Bixby.model.ScheduledCommand
      hosts: hosts
      command_id: command.id
      stdin: stdin
      args: args
      env: env
      schedule_type: _.val(@ui.natural.radio) || _.val(@ui.cron.radio)
      schedule: @ui.cron.text.val()
      scheduled_at: @ui.natural.text.data("date")
      alert_on: _.vals(@ui.status.filter(":checked"))
      alert_users: alert_users
      alert_emails: @$("input.email_to_emails").val()

    sc.save {},
      success: =>
        @transition("scheduled_commands")

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

    # init collapsible tabs
    @ui.tab[1].addClass("in")
    _.each [1..3], (i) => @ui.tab[i].addClass("collapse")

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
