
namespace 'Bixby.model', (exports, top) ->

  class exports.Command extends Stark.Model
    Backprop.create_strings @, "repo", "name", "bundle", "command"
    Backprop.create @, "options"

    params: [ { name: "command", set_id: true } ]
    urlRoot: "/rest/commands"

    # Whether or not the command has any options/configuration
    has_options: ->
      opts = @get("options")
      opts? && ! _.isEmpty(opts)

    # Whether or not this command has any dynamic (enum) options
    # which the host/agent should be queried for.
    #
    # @return [Boolean]
    has_enum_options: ->
      return false if ! @has_options()
      need = false
      _.eachR @, @get("options"), (val, key) ->
        if val.type == "enum"
          need = true

      return need


  class exports.CommandList extends Stark.Collection
    model: exports.Command
    params: [ "repo" ]
    url: ->
      s = "/rest/commands"
      s += "?repo_id=#{@repo_id}" if @repo_id
      s

    comparator: (cmd) ->
      cmd.bundle + "-" + cmd.command
