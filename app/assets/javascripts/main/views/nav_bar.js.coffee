namespace "Bixby.view", (exports, top) ->

  class exports.NavBar extends Stark.Partial

    reuse: true
    template: "main/nav_bar"

    links: {
      "a.brand": [ "inventory" ]
      ".tab.inventory a": [ "inventory" ]
      ".tab.monitoring a": [ "monitoring" ]
      ".tab.repository a": [ "repository" ]

      # user menu
      "a#profile": [ "profile" ]
    }

    events: {
      "click a#logout": (e) ->
        v = @
        $.ajax("/users/sign_out", {
          type: "DELETE"
          data: _.csrf()
          success: ->
            v.app.current_user = null
            v.app.redir_to_login()
        })

      "change select#pretend": (e) ->
        view = @
        user_id = $(e.target).val() # new user id

        if !user_id? || user_id == ""
          user_id = @true_user.id # impersonation was cleared

        new Bixby.model.User().impersonate user_id, (data, status, xhr) ->
          view.$("li.dropdown").removeClass('open')
          view.current_user = Bixby.app.current_user = new Bixby.model.User(data)
          view.redraw()
          Bixby.app.transition Bixby.app.current_state.name
    }

    app_events: {
      "state:activate": (state) ->
        if state.tab? and state.tab != @current_tab
          $("div.navbar li.tab").removeClass("active")
          if @current_tab = state.tab
            $("div.navbar li.tab.#{@current_tab}").addClass("active")

    }

    is_impersonating: ->
      @true_user.id != @current_user.id

    render_partial_html: ->
      @current_user ||= (Bixby.app.current_user || Bixby.app.bootstrap_data.current_user)
      @true_user ||= Bixby.app.bootstrap_data.true_user
      @users ||= Bixby.app.bootstrap_data.users
      super

    after_render: ->
      @$("select#pretend").select2({ allowClear: true })
