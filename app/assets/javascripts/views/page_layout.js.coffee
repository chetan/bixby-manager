namespace "Bixby.view", (exports, top) ->

  class exports.PageLayout extends Stark.View

    reuse: true
    el: "#body"
    template: "page_layout"

    links: {
      "a.brand": [ "inventory" ]
      ".tab.inventory a": [ "inventory" ]
      ".tab.monitoring a": [ "monitoring" ]
    }

    events: {
      "click a#logout": (e) ->
        v = @
        $.ajax("/logout", {
          success: ->
            v.app.current_user = null
            v.app.redir_to_login()
        })
    }

    app_events: {
      "state:activate": (state) ->
        if state.tab? and state.tab != @current_tab
          @current_tab = state.tab
          $("div.navbar li.tab").removeClass("active")
          $("div.navbar li.tab.#{@current_tab}").addClass("active")

    }

    render: ->
      super
      @breadcrumb = @partial(exports.Breadcrumb)
      @$("#breadcrumb").append(@breadcrumb.$el)
