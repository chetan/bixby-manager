namespace "Bixby.view", (exports, top) ->

  class exports.SelectUser extends Stark.Partial
    className: "select_user"
    template: "main/_select_user"

    after_render: ->
      @$("select#users").select2()
