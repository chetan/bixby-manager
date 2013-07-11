
# Applies a mailcheck.js popover to the target element
#
# @param [Element] target
_.mailcheck = (target) ->
  Kicksend.mailcheck.run({
    email: $(target).val()
    suggested: (suggestion) ->
      $(target).popover({
        content: "Did you mean " + suggestion.full + "?"
      }).popover("show")

    empty: ->
      $(target).popover("hide")
    })

# setTimeoutR - allows passing timeout as first param
window.setTimeoutR = (timeout, func) ->
  window.setTimeout(func, timeout)

# split which handles empty string correctly
_.split = (str, regex) ->
  if ! str
    return []
  return str.split(regex)

# Check whether the given element is in the current viewport
#
# via: http://stackoverflow.com/questions/487073/check-if-element-is-visible-after-scrolling#488073
_.isScrolledIntoView = (el) ->
  docViewTop = $(window).scrollTop()
  docViewBottom = docViewTop + $(window).height()

  elTop = $(el).offset().top
  elBottom = elTop + $(el).height()

  return ((elBottom <= docViewBottom) && (elTop >= docViewTop))

_.icon = (icon) ->
  "<i class='icon-#{icon}'></i>"

_.disable = (el) ->
  $(el).addClass("disabled")

_.enable = (el) ->
  $(el).removeClass("disabled")

_.pass = (el) ->
  $(el).addClass("pass").removeClass("fail")

_.fail = (el) ->
  $(el).addClass("fail").removeClass("pass")

# Retrieve the value of the given [input] element. Properly handles
# checkboxes
_.val = (el) ->
  if el.length
    el = $(el[0])
  else
    el = $(el)

  if el.prop("type") == "checkbox"
    return el.prop("checked")
  else
    return el.val()
