
# Customize js & sass compressors

begin
  require 'rake/hooks'

  before 'assets:precompile' do
    # remove all comments
    require 'uglifier'
    Uglifier::DEFAULTS[:output][:comments] = :none
    require 'sass'
    module Sass::Tree
      class CommentNode < Node
        def invisible?
          # override to silence 'loud' comments, e.g., /*! foobar */
          @type == :silent || style == :compressed
        end
      end
    end

    # force ascii-only mode
    # (when true: escape Unicode characters in strings and regexps)
    # added after problemes with latest select2
    # see also: http://stackoverflow.com/a/16826131
    Uglifier::DEFAULTS[:output][:ascii_only] = true
    # further fix for select2
    Uglifier::DEFAULTS[:output][:quote_keys] = true
  end

rescue LoadError
end
