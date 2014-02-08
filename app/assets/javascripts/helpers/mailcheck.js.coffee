
# Applies a mailcheck.js popover to the target element
#
# @param [Element] target
_.mailcheck = (target) ->
  Kicksend.mailcheck.run({
    email: $(target).val()
    suggested: (suggestion) ->
      $(target).popover({
        trigger: "manual"
        content: "Did you mean " + suggestion.full + "?"
      }).popover("show")

    empty: ->
      $(target).popover("hide")
    })
