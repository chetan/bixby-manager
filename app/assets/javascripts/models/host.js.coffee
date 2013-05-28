
namespace 'Bixby.model', (exports, top) ->

  class exports.Host extends Stark.Model
    urlRoot: "/rest/hosts"

    initialize: (data) ->
      @extract_param(data, "host", true)

    name: ->
      name = (@get("hostname") || @get("ip"))
      if @get("alias")? && @get("alias").length > 0
        name += " (" + @get("alias") + ")"
      return name

    tags: ->
      return _.split @get("tags"), ","

    has_tag: (tag) ->
      return _.include(@tags(), tag)

    is_new: ->
      return @has_tag("new")

    add_tag: (tag) ->
      tags = @tags()
      tags.push(tag)
      @set_tags(tags)

    remove_tag: (tag) ->
      @set_tags _.reject(@tags(), (t) -> t == tag)

    set_tags: (tags) ->
      if ! _.isString(tags)
        tags = tags.join(",")

      @set("tags", tags, {silent: true})

  class exports.HostList extends Stark.Collection
    model: exports.Host
    url: ->
      s = "/rest/hosts"
      if @query
        s += "?q=" + @query.replace(/#/, "%23")
      return s

    comparator: (host) ->
      host.name()
