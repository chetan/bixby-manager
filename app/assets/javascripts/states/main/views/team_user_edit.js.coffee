
namespace "Bixby.view", (exports, top) ->

  class exports.TeamUserEdit extends Stark.View
    el: "div#content"
    template: "main/team_user_edit"

    events:
      "focusout input#email": (e) ->
        _.mailcheck(e.target)

      "keyup input#username": (e) -> @validate_username(e)

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

    validate_username: _.debounceR 200, (e) ->
      span = @$("div.valid.username")
      _.unique_val e.target, (u) =>
        if u && u != @current_user.username
          # check if its valid/not taken
          new Bixby.model.User().is_valid_username u, (data, status, xhr) =>
            if data.valid == true
              _.pass span, _.icon("ok")
              @enable_save()
            else
              _.fail span, data.error
              @disable_save()

        else
          _.pass span
          @enable_save()

    after_render: ->
      @$("a[data-toggle='tooltip']").tooltip()
