
namespace 'Bixby.model', (exports, top) ->

  class exports.User extends Stark.Model
    @key: "user"
    @props
      _strings: ["name", "username", "email", "phone", "org", "tenant", "invited_by"]
      _dates:   ["created_at", "last_sign_in_at", "invite_created_at", "invite_accepted_at"]
      _ints:    ["invited_by_id"]
      _bools:   ["otp_required_for_login"]

    urlRoot: "/rest/users"
    params: [ { name: "user", set_id: true } ]

    @impersonate: (user_id, callback) ->
      $.ajax @.prototype.urlRoot + "/impersonate?user_id=" + user_id,
        dataType: "json"
        success: callback

    @invite: (name, username, email, callbacks) ->
      $.ajax "/rest/users/create_invite",
        type: "POST",
        data: _.csrf({name: name, username: username, email: email}),
        error: callbacks.error
        success: callbacks.success

    get_name: ->
      @get("name") || @get("username")

    get_status: ->
      status = if @last_sign_in_at
        "Active"
      else if @invite_created_at && !@invite_accepted_at
        "Invite Pending"
      else
        "Never logged in"

    gravatar: ->
      if Bixby.app.dev || Bixby.app.env == "integration"
        # avoid hitting gravatar.com in dev or integration environments
        # gravatar seems to give phantomjs a lot of grief due to slow loads
        # and timeouts
        return "/images/gravatar_dev.jpg"
      else
        url = "https://www.gravatar.com/avatar/"
        email = $.trim(@get("email"))
        return url + md5(email) + "?d=mm"

    otp: ->
      otp_auth_user = @username + "@bixby"
      return "otpauth://totp/" + otp_auth_user + "?secret=" + @get("gauth_secret")

    @is_valid_username: (username, callback) ->
      $.ajax @prototype.urlRoot + "/valid?username=" + username,
        dataType: "json"
        success: callback

    confirm_password: (pw, callback) ->
      $.ajax @urlRoot + "/confirm_password",
        type: "POST"
        dataType: "json"
        data: _.csrf({ id: @id, password: pw })
        success: (data, textStatus, jqXHR) ->
          callback.call(@, data)

    confirm_token: (tk, callback) ->
      $.ajax @urlRoot + "/confirm_token",
        type: "POST"
        dataType: "json"
        data: _.csrf({ id: @id, token: tk })
        success: (data, textStatus, jqXHR) ->
          callback.call(@, data)

    can: (permission) ->
      # TODO implement resource checks as well
      !! _.find @get("permissions"), (p) -> !p.resource? && p.name == permission

    # Format a date/time
    # TODO according to user's preferences
    format_datetime: (t) ->
      return "" if !t
      return moment(t).format("L HH:mm:ss Z")

  class exports.UserList extends Stark.Collection
    model: exports.User
    @key: "users"
    state:
      pageSize: 100
    url: "/rest/users"

    comparator: (user) ->
      user.get_name()
