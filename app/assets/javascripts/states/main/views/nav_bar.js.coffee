namespace "Bixby.view", (exports, top) ->

  class exports.NavBar extends Stark.Partial

    reuse: true
    template: "main/nav_bar"

    links:
      # inventory
      "a.navbar-brand":   "inventory"
      ".tab.inventory a": "inventory"

      # monitoring
      ".tab.monitoring.primary a":         "monitoring_overview"
      ".tab.monitoring a.overview":        "monitoring_overview"
      ".tab.monitoring a.check_templates": "mon_check_templates"
      ".tab.monitoring a.schedules":       "mon_oncalls"

      # runbooks
      ".tab.runbooks.primary a":            "runbooks"
      ".tab.runbooks a.run":                "runbooks"
      ".tab.runbooks a.scheduled_commands": "scheduled_commands"
      ".tab.runbooks a.logs":               "runbooks_logs"
      ".tab.runbooks a.repositories":       "repository"

      # user menu
      "a#profile":         "profile"

    events:
      "click a.run, .tab.runbooks.primary a": (e) ->
        _.cancelEvents(e)
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

      "click a": (e) ->
        # hide the navbar-toggle on click (only visible on xs or sm screens)
        e = $(e.target)
        if !(e.hasClass("dropdown-toggle") or e.parent().hasClass("dropdown-toggle") or e.hasClass("navbar-brand"))
          @$("button.navbar-toggle:visible").click()

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

    app_events:
      "state:activate": (state) ->
        @set_current_state(state)

    impersonate: (user_id) ->
      return if !@true_user.can("impersonate_users")

      if !user_id? || user_id == ""
        user_id = @true_user.id # impersonation was cleared

      Bixby.model.User.impersonate user_id, (data, status, xhr) =>
        @$("li.dropdown").removeClass('open')
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
      el = @$("a.help").popover("destroy")
      if text = Bixby.app.current_state.help
        el.attr("title", "").popover({ title: null, content: @markdown(text), html: true })
        el.attr("title", "Help").removeClass("disabled")
      else
        el.addClass("disabled").attr("title", "No help available on this screen")

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
        @$("#{target}.#{m}").addClass("dropdown")
        @$("#{target}.#{m} a").first().addClass("dropdown-toggle").on "click.dropdown.#{m}.mobile", $.fn.dropdown.Constructor.prototype.toggle

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
