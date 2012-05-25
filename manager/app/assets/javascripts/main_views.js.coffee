
namespace "Bixby.view", (exports, top) ->

  class exports.PageLayout extends Stark.View

    el: "#body"
    template: "page_layout"

    events: {
      "click a.brand": ->
        @transition "inventory"

      "click .tab.inventory": ->
        @transition "inventory"

      "click .tab.monitoring": ->
        @transition "monitoring"
    }

    app_events: {
      "state:activate": (state) ->
        if state.tab? and state.tab != @current_tab
          @current_tab = state.tab
          $("div.navbar li.tab").removeClass("active")
          $("div.navbar li.tab.#{@current_tab}").addClass("active")
    }

  class exports.Spinner extends Stark.View
    opts:
      lines: 12
      length: 7
      width: 4
      radius: 10
      color: '#000'
      speed: 1
      trail: 60
      shadow: false
      hwaccel: false
      className: 'spinner'
      zIndex: 2e9
      top: '0'
      left: '0'

    initialize: (target) ->
      super
      if _.isArray(target)
        target = target[0]
      @target = $(target)
      @render(@target)

    render: (target) ->
      @target = $(target)
      @target.height(60)
      @spinner = new window.Spinner(@opts).spin(@target[0])

    stop: ->
      @spinner.stop()
      @target.height("auto")
