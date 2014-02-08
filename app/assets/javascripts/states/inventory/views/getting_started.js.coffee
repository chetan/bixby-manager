namespace "Bixby.view.inventory", (exports, top) ->

  class exports.GettingStarted extends Stark.View
    el: "div.inventory_content"
    template: "inventory/getting_started"

    events:
      "focusin input.install": _.select_text
