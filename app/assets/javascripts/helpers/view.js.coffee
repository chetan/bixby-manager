
Stark.View.helpers ||= {}

_.extend Stark.View.helpers,

  # Process a given string containing Markdown syntax
  #
  # @param [String] str
  # @param [Boolean] wrap       wrap the result in a div.markdown (defaults to true)
  #
  # @return [String] str converted to html
  markdown: (str, wrap) ->
    if !wrap?
      wrap = true
    converter = new Markdown.Converter()
    html = converter.makeHtml(str)
    if wrap
      html = '<div class="markdown">' + html + '</div>'
    return html

  help: (body) ->
    opts = if _.isObject(body)
      body
    else
      { body: body }

    return @include_partial(Bixby.view.Help, opts)

  format_datetime: (t) ->
    return Bixby.app.current_user.format_datetime(t)

  format_relative_time: (t) ->
    return "" if !t
    return moment(t).fromNow()
