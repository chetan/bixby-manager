
namespace 'Bixby.model', (exports, top) ->

  class exports.Command extends Stark.Model
    @key: "command"
    @props
      _strings: ["repo", "name", "desc", "location", "command", "help", "help_url"]
      _misc:    ["options", "bundle"]

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

    run: (hosts, args, stdin, env, successCb) ->

      if _.isString(env)
        # convert env string into an object hash of key/value pairs
        # expects env to have one pair on each line, separated by '=',
        # e.g., "foo=bar\nbaz=boo"
        e = {}
        env.split(/\n/).forEach (line) ->
          line = line.trim()
          i = line.indexOf('=')
          if i < 0
            return
          k = line.substr(0, i).trim()
          v = line.substr(i+1).trim()
          if v[0] == '"' || v[0] == "'"
            v = JSON.parse(v)
          e[k] = v
        env = e

      @ajax "post",
        url: @url() + "/run"
        data: {hosts: hosts, args: args, stdin: stdin, env: env}
        success: (data, status, xhr) =>
          successCb(data)
        error: (xhr, status, err) =>
          @log "error: ", err

    # Retrieve help text for this command
    help_html: ->
      s = ""

      if @get("help")
        s = @get("help")

      if url = @get("help_url")
        if matches = url.match(/https?:\/\/.*?\.wikipedia\.org\/wiki.*?\/(.*)$/)
          # add a cleaner link to the help text
          # https://en.wikipedia.org/wiki/Load_%28computing%29
          # becomes
          # [Load (computing) <icon external-link>](https://... "Read about 'Load (computing)' on Wikipedia")
          title = decodeURI(matches[1]).replace("_", " ")
          url = "[#{title} #{_.icon("external-link")}](#{url} \"Read about '#{title}' on Wikipedia\")"
        else
          url += " " + _.icon("external-link")
        s += "\n\nSee also: " + url

      return s

    # Get option name for display. Shows default value if present.
    # e.g., Foo Option
    #
    # @return [String] name
    @opt_name: (key, hash) ->
      return hash["name"] || _.split_cap(key)

  class exports.CommandList extends Stark.Collection
    model: exports.Command
    @key: "commands"
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
