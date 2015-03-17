
'use strict'

# Original Route/Router implementation from Chaplin
# https://github.com/chaplinjs/chaplin

# Copyright (C) 2012 Moviepilot GmbH, 9elements GmbH et al.

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

window.Stark or= {}

class Stark.Route

  @reservedParams: 'path changeURL'.split(' ')

  # attributes
  pattern:    null
  state_name: null

  paramNames: null
  regExp:     null


  constructor: (pattern, state_name, @options = {}) ->
    #console.debug 'Router#constructor'

    @pattern = pattern
    @state_name = state_name

    # Replace :parameters, collecting their names
    @paramNames = []
    pattern = pattern.replace /:(\w+)/g, @addParamName

    # Create the actual regular expression
    @regExp = new RegExp '^' + pattern + '\/?(?=\\?|$)' # End or begin of query string

  addParamName: (match, paramName) =>
    # Test if parameter name is reserved
    if _(Route.reservedParams).include(paramName)
      throw new Error "Route#new: parameter name #{paramName} is reserved"
    # Save parameter name
    @paramNames.push paramName
    # Replace with a character class
    '([\\w-:=%]+)'

  # Test if the route matches to a path (called by Backbone.History#loadUrl)
  test: (path) ->
    #console.debug 'Route#test', @, "path »#{path}«", typeof path

    # Test the main RegExp
    matched = @regExp.test path
    return false unless matched

    # Apply the parameter constraints
    constraints = @options.constraints
    if constraints
      params = @extractParams path
      for own name, constraint of constraints
        unless constraint.test(params[name])
          return false

    return true

  # The handler which is called by Backbone.History when the route matched.
  # It is also called by Router#route which might pass options
  handler: (path, options) =>
    # console.debug 'Route#handler', @, path, options

    # Build params hash
    params = @buildParams path, options
    # console.debug params

    # Publish a global routeMatch event passing the route and the params
    @app.publish 'app:route', @, params

  # Create a proper Rails-like params hash, not an array like Backbone
  # `matches` and `additionalParams` arguments are optional
  buildParams: (path, options) ->
    #console.debug 'Route#buildParams', path, options

    params = @extractParams path

    # Add additional params from options
    # (they might overwrite params extracted from URL)
    _(params).extend @options.params

    # Add a param whether to change the URL
    # Defaults to false unless explicitly set in options
    params.changeURL = Boolean(options and options.changeURL)

    # Add a param with the whole path match
    params.path = path

    params

  # Extract parameters from the URL
  extractParams: (path) ->
    params = {}

    # Apply the regular expression
    matches = @regExp.exec path
    return params if !matches

    # Fill the hash using the paramNames and the matches
    for match, index in matches.slice(1)
      paramName = @paramNames[index]
      params[paramName] = match.replace(/%23/, "#")

    params
