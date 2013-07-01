
namespace "Bixby.view", (exports, top) ->

  class exports.ProfileEdit extends Stark.View
    el: "div#content"
    template: "main/profile_edit"

    events: {
      "blur input#email": (e) ->
        _.mailcheck(e.target)

      "keyup input#username": (e) ->
        u = $(e.target).val()
        if u && u != @current_user.username
          # check if its valid/not taken
          new Bixby.model.User().is_valid_username u, (data, status, xhr) ->
            if data.valid == true
              $("span#valid_username").html('<i class="icon-ok"></i>').css("color", "green").css("font-size", "larger")
            else
              $("span#valid_username").html('<i class="icon-remove"></i>').css("color", "red").css("font-size", "larger")
              $("span#valid_username").append("(" + data.error + ")")
        else
          $("span#valid_username").html('')

      "click button.submit": (e) ->
        e.preventDefault()
        attr = @get_attributes("name", "username", "email", "phone", "password", "password_confirmation")
        v = @
        @current_user.save attr, { success: (model, res) -> v.transition("profile") } # TODO handle error

    }

    after_render: ->
      @$("a[data-toggle='tooltip']").tooltip()
