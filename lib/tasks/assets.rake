
begin
  require 'sprockets-font_compressor'
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

  # create non-digest versions of files just in case
  after 'assets:precompile' do
    logger = Module.const_defined?("Logging".to_sym) ? ::Logging.logger["Assets::PreCompile"] : Rails.logger

    asset_path = File.join(Rails.root, "public", Rails.application.config.assets.prefix)
    manifest = File.join(asset_path, "manifest.json")

    files = Dir.glob(File.join(asset_path, "**/**"))
    files.each do |f|
      if f =~ /(\-[a-z0-9]{32})/ then
        fn = f.gsub(/(\-[a-z0-9]{32})/, '')
        next if fn == manifest
        logger.info "Writing #{fn}"
        FileUtils.copy_file(f, fn)
      end
    end
  end

rescue LoadError => ex
end
