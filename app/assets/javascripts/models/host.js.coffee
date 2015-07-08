
namespace 'Bixby.model', (exports, top) ->

  class exports.Host extends Stark.Model
    @key: "host"
    urlRoot: "/rest/hosts"
    params: [ { name: "host", set_id: true } ]

    @props
      _strings: ["hostname", "alias", "desc", "ip", "org"]
      _dates: ["last_seen_at"]
      _bools: ["is_connected"]

    name: ->
      if @get("alias")? && @get("alias").length > 0
        return @get("alias")
      @get("hostname")

    tags: ->
      return _.split(@get("tags"), ",").sort()

    has_tag: (tag) ->
      return _.include(@tags(), tag)

    is_new: ->
      return @has_tag("new")

    is_active: ->
      # active if currently connected OR last connected in the last 7 days
      @get("is_connected") || (@get("last_seen_at") && @get("last_seen_at").isAfter( moment().startOf("day").subtract(7, "days") ))

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

    last_seen_label: ->
      if seen = @get("last_seen_at")
        "Agent last seen " + Bixby.app.current_user.format_datetime(seen)
      else
        "Agent has never connected"

    last_seen_relative: ->
      moment(@last_seen_at).fromNow()


    # API methods

    # Inventory#update_facts
    update_facts: (callback) ->
      $.getJSON @url() + "/update_facts", callback

    get_metadata: (callback) ->
      return if @_metadata_loaded? || @has("metadata")
      $.getJSON @url() + "/metadata", callback
      @_metadata_loaded = true

    # Monitoring#update_check_config
    update_check_config: (callback) ->
      $.getJSON @url() + "/update_check_config", callback


  class exports.HostList extends Stark.Collection
    model: exports.Host
    @key: "hosts"
    url: ->
      s = "/rest/hosts"
      if @query
        s += "?q=" + encodeURIComponent(@query.replace(/#/, "%23"))
      return s

    comparator: (host) ->
      host.name()
