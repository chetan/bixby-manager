namespace "Bixby.view.inventory", (exports, top) ->

  class exports.HostTags extends Stark.Partial
    template: "inventory/_host_tags"
    bindings: [ "host" ]

  class exports.HostTagItem extends Stark.Partial
    template: "inventory/_host_tag_link"
    tagName: "li"

    links: {
      "a": [ "inv_search", (el) -> { query: "tag:#{@tag}" } ]
    }
