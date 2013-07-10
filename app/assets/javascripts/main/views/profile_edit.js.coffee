
namespace "Bixby.view", (exports, top) ->

  class exports.ProfileEdit extends Stark.View
    el: "div#content"
    template: "main/profile_edit"

    events: {
      "focusout input#email": (e) ->
        _.mailcheck(e.target)

      "keyup input#username": _.debounceR 200, (e) ->
        v = @
        span = @$("span.valid.username")
        u = @$(e.target).val()
        if u && u != @current_user.username
          # check if its valid/not taken
          new Bixby.model.User().is_valid_username u, (data, status, xhr) ->
            if data.valid == true
              _.pass span.html('<i class="icon-ok"></i>')
              v.enable_save()
            else
              _.fail span.html('<i class="icon-remove"></i>').append("(#{data.error})")
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
      _.enable @$("button.submit")

    disable_save: ->
      _.disable @$("button.submit")

    validate_password: _.debounceR 50, (e) ->
      span = @$("span.valid.password_confirmation")
      p = @$("#password").val()
      if p && p == @$("#password_confirmation").val()
        _.pass span.html('<i class="icon-ok"></i>')
        @enable_save()
      else
        _.fail span.html('<i class="icon-remove"></i>  (passwords must match)')
        @disable_save()

    after_render: ->
      @$("a[data-toggle='tooltip']").tooltip()
