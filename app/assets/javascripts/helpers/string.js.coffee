
# Split which handles empty string correctly
#
# @param [String] str
# @param [RegExp] regex
#
# @return [Array<String>] returns an empty array if string is null or empty
_.split = (str, regex) ->
  if !str
    return []
  return str.split(regex)

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
