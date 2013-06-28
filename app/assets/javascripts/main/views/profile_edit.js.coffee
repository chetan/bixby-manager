
namespace "Bixby.view", (exports, top) ->

  class exports.ProfileEdit extends Stark.View
    el: "div#content"
    template: "main/profile_edit"

    events: {
      "blur input#email": (e) ->
        @log "firing mailcheck"
        _.mailcheck(e.target)

    }

    after_render: ->
      @$("a[data-toggle='tooltip']").tooltip()
