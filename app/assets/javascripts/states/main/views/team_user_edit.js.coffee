
namespace "Bixby.view", (exports, top) ->

  class exports.TeamUserEdit extends Stark.View
    el: "div#content"
    template: "main/team_user_edit"

    events:
      "focusout input#email": (e) ->
        _.mailcheck(e.target)

      "keydown input#username": _.debounceR 50, true, _.wait_valid

      "keyup input#username": (e) ->
        @validate_username e, @user, (is_valid) ->
          if is_valid
            @enable_save()
          else
            @disable_save()

      "click button.submit": (e) ->
        e.preventDefault()
        return if @$(e.target).hasClass("disabled")

        attr = @get_attributes("name", "username", "email", "phone")
        @user.save attr,
          success: (model, res) => @transition("team_user_view", {user: @user})

      "click button.cancel": (e) ->
        @transition("team_user_view", {user: @user})

    enable_save: ->
      _.enable @$("button.submit")

    disable_save: ->
      _.disable @$("button.submit")

    validate_username: _.debounceR 200, Bixby.helpers.Validation.validate_username

    after_render: ->
      @$("a[data-toggle='tooltip']").tooltip()
