namespace "Bixby.view", (exports, top) ->

  class exports.NavBar extends Stark.Partial

    reuse: true
    template: "main/nav_bar"

    links:
      # inventory
      "a.navbar-brand":   "inventory"
      ".tab.inventory a": "inventory"

      # monitoring
      ".tab.monitoring.primary a:first":   "monitoring_overview"
      ".tab.monitoring a.overview":        "monitoring_overview"
      ".tab.monitoring a.check_templates": "mon_check_templates"
      ".tab.monitoring a.schedules":       "mon_oncalls"

      # runbooks
      ".tab.runbooks.primary a:first":      "runbooks"
      ".tab.runbooks a.run":                "runbooks"
      ".tab.runbooks a.scheduled_commands": "scheduled_commands"
      ".tab.runbooks a.logs":               "runbooks_logs"
      ".tab.runbooks a.repositories":       "repository"

      # user menu
      "a#profile":         "profile"
      "a#team":            "team"

    events:
      "click a.run, .tab.runbooks.primary a:first": (e) ->
        @$(".tab.runbooks").addClass("active")
        _.cancelEvents(e)
        @close_nav()
        if !@current_user.get("otp_required_for_login")
          return @transition("runbooks")

        c = @create_partial Bixby.view.ConfirmIdentity,
          confirm_password: false,
          confirm_token: true
          cb: (confirmed) =>
            if confirmed
              @transition("runbooks", {password_confirmed: true})
            else
              alert("fail")
        c.render()

      "click .tab.monitoring.primary a:first": (e) ->
        @$(".tab.monitoring").addClass("active")

      "click a": (e) ->
        # hide the navbar-toggle on click (only visible on xs or sm screens)
        if @$(".navbar-collapse.in").length > 0 && !$(e.target).hasClass("dropdown-toggle")
          @close_nav()

      "click a#logout": (e) ->
        $.ajax "/logout",
          type: "POST"
          data: _.csrf()
          success: =>
            @app.current_user = null
            @app.redir_to_login()

      "change select#pretend": (e) ->
        user_id = $(e.target).val() # new user id
        @impersonate(user_id)

      "click a#stop_impersonating": (e) ->
        @impersonate()

      "click a.help-alert": (e) ->
        # display help as alert box at top of page
        if (text = Bixby.app.current_state.help) && ($("div.help.alert").length == 0)
          html = @markdown(text)
          partial = @create_partial("main/_help_alert", {content: html})
          $("div#content").prepend(partial.render_partial_html())

    app_events:
      "state:activate": (state) ->
        # move progress bar to 100% and hide
        $("div.progress.loading div.progress-bar").removeClass("loading").addClass("loaded")
        $("div.progress.loading").addClass("hiding")
        @set_current_state(state)

      "state:before_activate": (new_state) ->
        $("div.help.alert").remove()

      "state:before_load": (new_state) ->
        # display progress bar
        $("div.progress.loading").removeClass("hiding").css({visibility: "visible"})
        # force the width to reset before showing loading transition
        $("div.progress.loading div.progress-bar").removeClass("loaded").width("0").addClass("loading")

    # Close nav menu if open
    close_nav: ->
      @$(".navbar-collapse.in").length > 0 && @$(".navbar-collapse").collapse("hide")
      @$("li.open").length > 0 && @$("li.open").removeClass("open")

    impersonate: (user_id) ->
      return if !@true_user.can("impersonate_users")

      if !user_id? || user_id == ""
        user_id = @true_user.id # impersonation was cleared

      Bixby.model.User.impersonate user_id, (data, status, xhr) =>
        @$("li.open").removeClass('open')
        @current_user = Bixby.app.current_user = new Bixby.model.User(data)
        @redraw()
        Bixby.app.transition Bixby.app.current_state.name


    is_impersonating: ->
      @true_user.id != @current_user.id

    render_partial_html: ->
      @current_user ||= (Bixby.app.current_user || Bixby.app.bootstrap_data.current_user)
      @true_user ||= (Bixby.app.bootstrap_data.true_user || @current_user)
      if @true_user.can("impersonate_users")
        @users ||= Bixby.app.bootstrap_data.users
      super

    set_current_state: (state) ->
      return if !state?
      @update_help(state)
      if state.tab?
        $("ul.nav li.tab").removeClass("active")
        @current_tab = state.tab
        $("ul.nav li.tab.#{@current_tab}").addClass("active")

    # Update the help popover/button
    update_help: (new_state) ->
      return if !Bixby.app.current_state
      el = @$("a.help[data-toggle='popover']").popover("destroy")
      if text = Bixby.app.current_state.help
        el.attr("title", "").popover({ title: null, content: @markdown(text), html: true })
        el.attr("title", "Help").removeClass("disabled")
      else
        @$("a.help").addClass("disabled").attr("title", "No help available on this screen")

    resize_nav: ->
      # in case we are firing after a resize, set the active tab
      if !@$("ul.nav li.tab.active").length
        @set_current_state(Bixby.app.current_state)

      # depending on resolution, correct the nav
      if _.is_xs()
        target = "li.tab.primary"
      else
        target = "li.tab.split"

      # attach dropdown menu to active <li>
      _.each ["monitoring", "runbooks"], (m) =>
        @$("li.tab.#{m} ul.dropdown-menu").detach().appendTo("#{target}.#{m}")
        @$("#{target}.#{m} .dropdown-toggle").on "click.dropdown.#{m}.mobile", $.fn.dropdown.Constructor.prototype.toggle

    after_render: ->
      @resize_nav()

      @$("select#pretend").select2
        allowClear: true
        matcher: (term, text, opt) ->
          # use default matcher to evaluate the option as well its option group label
          optgroup = $(opt).parent().attr("label")
          $.prototype.select2.defaults.matcher(term, text) ||
            $.prototype.select2.defaults.matcher(term, optgroup)

      $(window).on "resize.navbar", _.debounceR 500, =>
        @redraw()

    dispose: ->
      super
      @$("a.help").popover("destroy")
      $(window).off "resize.navbar"
