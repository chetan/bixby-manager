
namespace 'Bixby.model', (exports, top) ->

  class exports.Host extends Stark.Model
    urlRoot: "/rest/hosts"
    params: [ { name: "host", set_id: true } ]

    name: ->
      name = (@get("hostname") || @get("ip"))
      if @get("alias")? && @get("alias").length > 0
        name += " (" + @get("alias") + ")"
      return name

    tags: ->
      return _.split(@get("tags"), ",").sort()

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

      @set("tags", tags)


    # API methods

    # Inventory#update_facts
    update_facts: (callback) ->
      $.getJSON @url() + "/update_facts", callback

    # Monitoring#update_check_config
    update_check_config: (callback) ->
      $.getJSON @url() + "/update_check_config", callback


  class exports.HostList extends Stark.Collection
    model: exports.Host
    url: ->
      s = "/rest/hosts"
      if @query
        s += "?q=" + @query.replace(/#/, "%23")
      return s

    comparator: (host) ->
      host.name()
