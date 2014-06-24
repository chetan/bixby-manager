
namespace 'Bixby.model', (exports, top) ->

  class exports.Command extends Stark.Model
    Backprop.create_strings @, "repo", "name", "desc", "location", "bundle", "command"
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

    run: (hosts, args, stdin, successCb) ->
      @ajax "post",
        url: @url() + "/run"
        data: {hosts: hosts, args: args, stdin: stdin}
        success: (data, status, xhr) =>
          successCb(data)
        error: (xhr, status, err) =>
          @log "error: ", err


    # Get option name for display. Shows default value if present.
    # e.g., Foo Option [default: ``blah``]
    #
    # @return [String] markdown formatted html
    @opt_name: (key, hash) ->
      s = (hash["name"] || _.split_cap(key))
      if hash["default"]?
        s += "<br/><span class='default-opt'>[default: ``#{hash['default']}``]</span>"

      md = new Markdown.Converter()
      return "<span class='markdown'>" + md.makeHtml(s) + "</span>"


  class exports.CommandList extends Stark.Collection
    model: exports.Command
    params: [ "repo" ]
    url: ->
      s = "/rest/commands"
      s += "?repo_id=#{@repo_id}" if @repo_id
      s

    comparator: (cmd) ->
      if cmd.isNew()
        ""
      else
        (cmd.bundle.path + "-" + cmd.name).toLowerCase()
