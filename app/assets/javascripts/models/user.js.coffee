
namespace 'Bixby.model', (exports, top) ->

  class exports.User extends Stark.Model
    urlRoot: "/rest/users"
    Backprop.create_strings @, "name", "username", "email", "phone", "org", "tenant"

    get_name: ->
      @get("name") || @get("username")

    gravatar: ->
      if Bixby.app.dev
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

  class exports.UserList extends Stark.Collection
    model: exports.User
    url: "/rest/users"

    comparator: (user) ->
      user.get_name()
