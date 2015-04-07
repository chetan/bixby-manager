
namespace 'Bixby.helpers', (exports, top) ->
  exports.Validation =

    # Username input validation routine
    #
    # @param [Event] e         keyup Event
    # @param [User] user       user we are validating for
    validate_username: (e, user, cb) ->
      span = @$("div.valid.username")
      _.unique_val e.target, (u) =>
        if u && u != user.username
          Bixby.model.User.is_valid_username u, (data, status, xhr) =>
            if data.valid == true
              _.pass span, "available"
              cb.call(@, true)
            else
              _.fail span, data.error
              cb.call(@, false)

        else
          _.clear_validation(span)
          cb.call(@, true)


