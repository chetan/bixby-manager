namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Check extends Stark.Partial

    className: "check"
    template: "monitoring/_check"

    after_render: ->

