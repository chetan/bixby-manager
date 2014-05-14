
# Check whether the given element is visible in the current viewport
#
# via: http://stackoverflow.com/questions/487073/check-if-element-is-visible-after-scrolling#488073
#
# @param [Element] el
# @param [Boolean] partial          Whether or not to test for partial visibility (default: false)
#
# @return [Boolean] true if element is visible
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

# Create a font-awesome icon
#
# @param [String] icon        icon name (without fa-)
# @param [String] clazz       extra classes to add to icon
#
# @return [String] icon html, e.g., <i class="fa fa-circle"></i>
_.icon = (icon, clazz) ->
  c = "fa fa-#{icon}"
  if clazz?
    c += " " + clazz
  "<i class='#{c}'></i>"

# Add disabled class to given el
_.disable = (el) ->
  $(el).addClass("disabled")

# Remove disabled class from given el
_.enable = (el) ->
  $(el).removeClass("disabled")

# Add pass and remove fail, set the given html
_.pass = (el, html) ->
  html = "" if not html?
  $(el).addClass("pass").removeClass("fail").html(html)
  p = $(el).parent()
  if p[0].nodeName == "DIV" && p.hasClass("has-feedback")
    p.addClass("has-success").removeClass("has-error")

# Add fail and remove pass, set the given html
_.fail = (el, msg) ->
  if msg && msg.length > 0 && msg.charAt(0) != ' '
    msg = " " + msg
  $(el).addClass("fail").removeClass("pass").html(_.icon("exclamation-circle") + msg)
  p = $(el).parent()
  if p[0].nodeName == "DIV" && p.hasClass("has-feedback")
    p.addClass("has-error").removeClass("has-success")

# Dim the given element
_.dim = (el) ->
  if !el.length?
    el = $(el)
  el[0]._bg_color = el.css("background-color")
  el.css({"background-color": "black", "opacity": 0.3})

# Undim the given element
_.undim = (el) ->
  if !el.length?
    el = $(el)
  el.css({"background-color": el[0]._bg_color, "opacity": 1})
