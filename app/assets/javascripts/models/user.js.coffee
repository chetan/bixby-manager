
namespace 'Bixby.model', (exports, top) ->

  class exports.User extends Stark.Model

    name: ->
      @get("name") || @get("username")
