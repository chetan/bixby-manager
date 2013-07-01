
namespace "Bixby.view", (exports, top) ->

  class exports.ProfileEdit extends Stark.View
    el: "div#content"
    template: "main/profile_edit"

    events: {
      "blur input#email": (e) ->
        _.mailcheck(e.target)

      "keyup input#username": _.debounceR 200, (e) ->
        span = @$("span.valid.username")
        u = $(e.target).val()
        if u && u != @current_user.username
          # check if its valid/not taken
          new Bixby.model.User().is_valid_username u, (data, status, xhr) ->
            if data.valid == true
              span.html('<i class="icon-ok"></i>').addClass("pass").removeClass("fail")
            else
              span.html('<i class="icon-remove"></i>').addClass("fail").removeClass("pass")
              span.append("(" + data.error + ")")
        else
          span.html('')

      "click button.submit": (e) ->
        e.preventDefault()
        attr = @get_attributes("name", "username", "email", "phone", "password", "password_confirmation")
        v = @
        @current_user.save attr, { success: (model, res) -> v.transition("profile") } # TODO handle error

    }

    after_render: ->
      @$("a[data-toggle='tooltip']").tooltip()
