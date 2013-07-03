namespace "Bixby.view", (exports, top) ->

  class exports.PageLayout extends Stark.View

    reuse: true
    el: "#body"
    template: "main/page_layout"

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
        $.ajax("/logout", {
          type: "POST"
          data: _.csrf()
          success: ->
            v.app.current_user = null
            v.app.redir_to_login()
        })
    }

    app_events: {
      "state:activate": (state) ->
        if state.tab? and state.tab != @current_tab
          $("div.navbar li.tab").removeClass("active")
          if @current_tab = state.tab
            $("div.navbar li.tab.#{@current_tab}").addClass("active")

    }

    render: ->
      super
      @breadcrumb = @partial(exports.Breadcrumb)
      @$("#breadcrumb").append(@breadcrumb.$el)
