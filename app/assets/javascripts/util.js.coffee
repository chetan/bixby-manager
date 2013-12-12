
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
_.isScrolledIntoView = (el, partial) ->
  docViewTop = $(window).scrollTop()
  docViewBottom = docViewTop + $(window).height()

  elTop = $(el).offset().top
  elBottom = elTop + $(el).height()

  if partial
    # check if the element is partially visible
    return ((elTop < docViewBottom && elTop > docViewTop) || (elBottom > docViewTop && elBottom < docViewBottom))

  else
    # check if the entire element is visible
    return ((elBottom <= docViewBottom) && (elTop >= docViewTop))

_.icon = (icon) ->
  "<i class='fa fa-#{icon}'></i>"

_.disable = (el) ->
  $(el).addClass("disabled")

_.enable = (el) ->
  $(el).removeClass("disabled")

_.pass = (el, html) ->
  html = "" if not html?
  $(el).addClass("pass").removeClass("fail").html(html)

_.fail = (el, msg) ->
  if msg && msg.length > 0 && msg.charAt(0) != ' '
    msg = " " + msg
  $(el).addClass("fail").removeClass("pass").html(_.icon("remove") + msg)

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

# Select the text in the given input control when clicked
#
# Usage:
#
#   events:
#     "focusin input.install": _.select_text
#
_.select_text = (e) ->
  $(e.target).mouseup (e) ->
    setTimeoutR 0, ->
      e.target.select()
    $(this).unbind()

  setTimeoutR 0, ->
    e.target.select()

# Split the given string on a separator and capitalize each word
# ex: foo_bar -> Foo Bar
#
# @param [String] str
# @param [String] sep       default: _
#
# @return [String]
_.split_cap = (str, sep) ->
  sep = "_" if ! sep
  _.map(_.split(str, sep), (s) -> _.string.capitalize(s)).join(" ")

# Get all the captured groups in the string for the given regex
#
# @param [String] string
# @param [RegExp] regex     must have /g flag set
# @param [Integer] index    default = 1
#
# @return [Array<String>] captured groups
_.getMatches = (string, regex, index) ->
  index || (index = 1) # default to the first capturing group
  matches = []
  match = null
  while (match = regex.exec(string))
    matches.push(match[index])
  return matches
