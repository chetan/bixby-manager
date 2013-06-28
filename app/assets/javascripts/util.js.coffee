
# Applies a mailcheck.js popover to the target element
#
# @param [Element] target
_.mailcheck = (target) ->
  $(target).mailcheck({
  suggested: (el, suggestion) ->
    $(el).popover({
      content: "Did you mean " + suggestion.full + "?"
    }).popover("show")

  empty: (el) ->
    $(el).popover("hide")
  })
