
namespace "Bixby.view", (exports, top) ->

  class exports.ProfileEdit extends Stark.View
    el: "div#content"
    template: "main/profile_edit"

    events: {
      "focusout input#email": (e) ->
        _.mailcheck(e.target)

      "keyup input#username": _.debounceR 200, (e) ->
        v = @
        span = @$("div.valid.username")
        u = @$(e.target).val()
        if u && u != @current_user.username
          # check if its valid/not taken
          new Bixby.model.User().is_valid_username u, (data, status, xhr) ->
            if data.valid == true
              _.pass span, _.icon("ok")
              v.enable_save()
            else
              _.fail span, data.error
              v.disable_save()

        else
          _.pass span
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

    validate_password: _.debounceR 100, (e) ->
      div1 = "div.valid.password"
      div2 = "div.valid.password_confirmation"
      p = @$("#password").val()
      pc = @$("#password_confirmation").val()
      if p && p.length > 0
        if p.length < 8
          _.fail div1
          _.fail div2, 'must be at least 8 characters'
          @disable_save()
        else if p != pc
          _.fail div1
          _.fail div2, 'passwords must match'
          @disable_save()
        else
          _.pass div1
          _.pass div2
          @enable_save()
      else
        _.clear_valid_input(div1)
        _.clear_valid_input(div2)
        @enable_save()

    after_render: ->
      @$("a[data-toggle='tooltip']").tooltip()
