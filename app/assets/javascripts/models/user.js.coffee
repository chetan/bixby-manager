
namespace 'Bixby.model', (exports, top) ->

  class exports.User extends Stark.Model
    @key: "user"
    urlRoot: "/rest/users"
    Backprop.create_strings @, "name", "username", "email", "phone", "org", "tenant"

    @impersonate: (user_id, callback) ->
      $.ajax @.prototype.urlRoot + "/impersonate?user_id=" + user_id, {
        dataType: "json"
        success: callback
      }

    get_name: ->
      @get("name") || @get("username")

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

    is_valid_username: (username, callback) ->
      $.ajax @urlRoot + "/valid?username=" + username,
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

  class exports.UserList extends Stark.Collection
    model: exports.User
    @key: "users"
    url: "/rest/users"

    comparator: (user) ->
      user.get_name()
