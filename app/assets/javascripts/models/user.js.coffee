
namespace 'Bixby.model', (exports, top) ->

  class exports.User extends Stark.Model
    urlRoot: "/rest/users"
    Backprop.create_strings @, "name", "username", "email", "phone", "org", "tenant"

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

    is_valid_username: (username, callback) ->
      $.ajax @urlRoot + "/valid?username=" + username, {
        dataType: "json"
        success: callback
      }

    can: (permission) ->
      # TODO implement resource checks as well
      !! _.find @get("permissions"), (p) -> !p.resource? && p.name == permission

    impersonate: (user_id, callback) ->
      $.ajax @urlRoot + "/impersonate?user_id=" + user_id, {
        dataType: "json"
        success: callback
      }

  class exports.UserList extends Stark.Collection
    model: exports.User
    url: "/rest/users"

    comparator: (user) ->
      user.get_name()
