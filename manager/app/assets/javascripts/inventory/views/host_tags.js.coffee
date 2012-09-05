namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostTags extends Stark.View
    template: "inventory/_host_tags"
    bindings: [ "host" ]

    render: ->
      super
      _.eachR @, @host.tags(), (tag) ->
        @add_tag(tag)

    add_tag: (tag) ->
      @$("ul").append @partial(exports.HostTagItem, {tag: tag}).$el


  class exports.HostTagItem extends Stark.View
    template: "inventory/_host_tag_link"
    tagName: "li"

    links: {
      "a": [ "inv_search", (el) -> { query: "tag:#{@tag}" } ]
    }
