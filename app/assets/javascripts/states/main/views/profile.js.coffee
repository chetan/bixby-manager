
namespace "Bixby.view", (exports, top) ->

  class exports.Profile extends Stark.View
    el: "div#content"
    template: "main/profile"

    events:
      "click .btn-edit": (e) ->
        @transition("profile_edit")

    after_render: ->
      @$("a[data-toggle='tooltip']").tooltip()
