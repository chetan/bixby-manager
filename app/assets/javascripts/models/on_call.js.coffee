
namespace 'Bixby.model', (exports, top) ->

  class exports.OnCall extends Stark.Model
    urlRoot: "/rest/on_calls"

    set_users: (users) ->
      if ! _.isString(users)
        users = users.join(",")

      @set("users", users, {silent: true})


  class exports.OnCallList extends Stark.Collection
    model: exports.OnCall
    url: "/rest/on_calls"
