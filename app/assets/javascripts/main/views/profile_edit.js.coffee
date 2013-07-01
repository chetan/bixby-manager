
namespace "Bixby.view", (exports, top) ->

  class exports.ProfileEdit extends Stark.View
    el: "div#content"
    template: "main/profile_edit"

    events: {
      "blur input#email": (e) ->
        _.mailcheck(e.target)

      "keyup input#username": _.debounceR 200, (e) ->
        v = @
        span = @$("span.valid.username")
        u = @$(e.target).val()
        if u && u != @current_user.username
          # check if its valid/not taken
          new Bixby.model.User().is_valid_username u, (data, status, xhr) ->
            if data.valid == true
              span.html('<i class="icon-ok"></i>').addClass("pass").removeClass("fail")
              v.enable_save()
            else
              span.html('<i class="icon-remove"></i>').addClass("fail").removeClass("pass")
              span.append("(" + data.error + ")")
              v.disable_save()

        else
          span.html('')
          v.enable_save()

      "keyup input#password": (e) -> @validate_password(e)
      "keyup input#password_confirmation": (e) -> @validate_password(e)

      "click button.submit": (e) ->
        e.preventDefault()
        return if @$(e.target).hasClass("disabled")

        attr = @get_attributes("name", "username", "email", "phone", "password", "password_confirmation")
        v = @
        @current_user.save attr, { success: (model, res) -> v.transition("profile") } # TODO handle error

    }

    enable_save: ->
      @$("button.submit").removeClass("disabled")

    disable_save: ->
      @$("button.submit").addClass("disabled")

    validate_password: _.debounceR 50, (e) ->
      span = @$("span.valid.password_confirmation")
      p = @$("#password").val()
      if p && p == @$("#password_confirmation").val()
        span.html('<i class="icon-ok"></i>').addClass("pass").removeClass("fail")
        @enable_save()
      else
        span.html('<i class="icon-remove"></i>').append("(passwords must match)").addClass("fail").removeClass("pass")
        @disable_save()

    after_render: ->
      @$("a[data-toggle='tooltip']").tooltip()
