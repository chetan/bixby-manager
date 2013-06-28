
namespace "Bixby.view", (exports, top) ->

  class exports.ProfileEdit extends Stark.View
    el: "div#content"
    template: "main/profile_edit"

    events: {
      "blur input#email": (e) ->
        _.mailcheck(e.target)

      "keyup input#username": (e) ->
        u = $(e.target).val()
        if u && u != @current_user.g("username")
          # check if its valid/not taken
          new Bixby.model.User().is_valid_username u, (data, status, xhr) ->
            if data.valid == true
              $("span#valid_username").html('<i class="icon-ok"></i>').css("color", "green").css("font-size", "larger")
            else
              $("span#valid_username").html('<i class="icon-remove"></i>').css("color", "red").css("font-size", "larger")
              $("span#valid_username").append("(" + data.error + ")")
        else
          $("span#valid_username").html('')


    }

    after_render: ->
      @$("a[data-toggle='tooltip']").tooltip()
