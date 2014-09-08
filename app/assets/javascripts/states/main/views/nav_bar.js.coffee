namespace "Bixby.view", (exports, top) ->

  class exports.NavBar extends Stark.Partial

    reuse: true
    template: "main/nav_bar"

    links:
      "a.navbar-brand":    "inventory"
      ".tab.inventory  a": "inventory"

      ".tab.monitoring a.overview": "monitoring_overview"
      ".tab.monitoring a.check_templates": "mon_check_templates"
      ".tab.monitoring a.schedules": "mon_oncalls"

      # ".tab.runbooks a.run": "runbooks" # TODO still need to create a link here..
      ".tab.runbooks a.repositories": "repository"

      # user menu
      "a#profile":         "profile"

    events:
      "click a.run": (e) ->
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
        v = @
        $.ajax("/logout", {
          type: "POST"
          data: _.csrf()
          success: ->
            v.app.current_user = null
            v.app.redir_to_login()
        })

      "change select#pretend": (e) ->
        user_id = $(e.target).val() # new user id
        @impersonate(user_id)

      "click a#stop_impersonating": (e) ->
        @impersonate()

    app_events:
      "state:activate": (state) ->
        @update_help(state)
        if state.tab? and state.tab != @current_tab
          $("ul.nav li.tab").removeClass("active")
          @current_tab = state.tab
          $("ul.nav li.tab.#{@current_tab}").addClass("active")

    impersonate: (user_id) ->
      return if !@true_user.can("impersonate_users")

      if !user_id? || user_id == ""
        user_id = @true_user.id # impersonation was cleared

      view = @
      Bixby.model.User.impersonate user_id, (data, status, xhr) ->
        view.$("li.dropdown").removeClass('open')
        view.current_user = Bixby.app.current_user = new Bixby.model.User(data)
        view.redraw()
        Bixby.app.transition Bixby.app.current_state.name


    is_impersonating: ->
      @true_user.id != @current_user.id

    render_partial_html: ->
      @current_user ||= (Bixby.app.current_user || Bixby.app.bootstrap_data.current_user)
      @true_user ||= (Bixby.app.bootstrap_data.true_user || @current_user)
      if @true_user.can("impersonate_users")
        @users ||= Bixby.app.bootstrap_data.users
      super

    # Update the help popover/button
    update_help: (new_state) ->
      return if !Bixby.app.current_state
      el = @$("a.help").popover("destroy")
      if text = Bixby.app.current_state.help
        el.attr("title", "").popover({ title: null, content: @markdown(text), html: true })
        el.attr("title", "Help").removeClass("disabled")
      else
        el.addClass("disabled").attr("title", "No help available on this screen")

    after_render: ->
      @$("select#pretend").select2({
        allowClear: true
        matcher: (term, text, opt) ->
          # use default matcher to evaluate the option as well its option group label
          optgroup = $(opt).parent().attr("label")
          $.prototype.select2.defaults.matcher(term, text) ||
            $.prototype.select2.defaults.matcher(term, optgroup)
        })

    dispose: ->
      super
      @$("a.help").popover("destroy")
