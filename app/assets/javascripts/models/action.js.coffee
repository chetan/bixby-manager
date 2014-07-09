
namespace 'Bixby.model', (exports, top) ->

  class exports.Action extends Stark.Model
    @key: "action"
    urlRoot: "/rest/actions"

  class exports.ActionList extends Stark.Collection
    model: exports.Action
    @key: "actions"
    url: -> "/rest/actions"
