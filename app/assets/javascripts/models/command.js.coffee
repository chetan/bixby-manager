
namespace 'Bixby.model', (exports, top) ->

  class exports.Command extends Stark.Model
    urlRoot: "/rest/commands"
    Backprop.create_strings @, "repo", "name", "bundle", "command", "options"
    Backprop.create @, "options"

  class exports.CommandList extends Stark.Collection
    model: exports.Command
    url: "/rest/commands"
