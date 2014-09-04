
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
    @_converter ||= new Markdown.Converter()
    html = @_converter.makeHtml(str)
    if wrap
      html = '<div class="markdown">' + html + '</div>'
    return html
