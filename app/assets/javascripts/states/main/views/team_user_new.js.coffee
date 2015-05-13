
namespace "Bixby.view", (exports, top) ->

  class exports.TeamUserNew extends Stark.View
    el: "div#content"
    template: "main/team_user_new"

    ui:
      name:     "input.name"
      username: "input.username"
      email:    "input.email"

    events:
      "click button.cancel": (e) ->
        @transition("team")

      "click button.submit": (e) ->
        name     = _.val(@ui.name)
        username = _.val(@ui.username)
        email    = _.val(@ui.email)
        Bixby.model.User.invite name, username, email,
          error: (jqXHR, status, err) ->
            data = JSON.parse(jqXHR.responseText)
            if data.error.match(/unknown username/)
              _.fail("div.valid.username", "bad username or email")
            else
              _.fail("div.valid.username", "error submitting reset request")

          success: (data, textStatus, jqXHR) ->
            $("div#success.modal").modal()


      "hidden.bs.modal div#success.modal": (e) ->
        @transition("team")

      "keydown input#username": _.debounceR 50, true, _.wait_valid

      "keyup input#username": (e) ->
        @validate_username e, new Bixby.model.User(), (is_valid) ->
          @$("input.username").data("valid", is_valid)
          @enable_submit()

      "keyup input.email": _.debounceR 50, (e) ->
        el = $(e.target).parent("div.form-group.has-feedback").find("div.valid")
        v = _.val(e.target)

        if v.length == 0
          @$("input.email").data("valid", false)
          _.clear_validation(el)
          @disable_submit()

        else if v.length > 0 && v.match(Backbone.Validation.patterns.email)
          @$("input.email").data("valid", true)
          _.pass(el)
          @enable_submit()

        else
          @$("input.email").data("false", true)
          _.fail(el, "valid email is required")
          @disable_submit()

    enable_submit: ->
      # only email is required; if username is given, then it must be valid
      if $("input.username").data("valid") != false && $("input.email").data("valid") == true
        _.enable @$("button.submit")
      else
        @disable_submit()

    disable_submit: ->
      _.disable @$("button.submit")

    validate_username: _.debounceR 200, Bixby.helpers.Validation.validate_username
