
namespace 'Bixby.model', (exports, top) ->

  class exports.User extends Stark.Model

    name: ->
      @get("name") || @get("username")

    gravatar: ->
      url = "https://www.gravatar.com/avatar/"
      email = $.trim(@get("email"))
      return url + md5(email) + "?d=mm"
