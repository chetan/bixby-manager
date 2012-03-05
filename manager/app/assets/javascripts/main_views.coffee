
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
      "nav:select_tab": (tab) ->
        $("div.navbar li.tab").removeClass("active")
        $("div.navbar li.tab.#{tab}").addClass("active")
    }
