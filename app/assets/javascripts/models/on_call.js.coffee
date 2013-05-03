
namespace 'Bixby.model', (exports, top) ->

  class exports.OnCall extends Stark.Model
    urlRoot: "/rest/on_calls"


  class exports.OnCallList extends Stark.Collection
    model: exports.OnCall
    url: "/rest/on_calls"
