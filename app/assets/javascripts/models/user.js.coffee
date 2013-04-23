
namespace 'Bixby.model', (exports, top) ->

  class exports.User extends Stark.Model

    name: ->
      @get("name") || @get("username")

    gravatar: ->
      if Bixby.app.dev
        return "/images/gravatar_dev.png"
      else
        url = "https://www.gravatar.com/avatar/"
        email = $.trim(@get("email"))
        return url + md5(email) + "?d=mm"
