
namespace 'Bixby.model', (exports, top) ->

  class exports.Action extends Stark.Model
    urlRoot: "/rest/actions"

  class exports.ActionList extends Stark.Collection
    model: exports.Action
    url: -> "/rest/actions"
