
begin
  require 'sprockets-font_compressor'
  require 'rake/hooks'

  before 'assets:precompile' do
    # remove all comments
    require 'uglifier'
    Uglifier::DEFAULTS[:output][:comments] = :none
  end

  # create non-digest versions of files just in case
  after 'assets:precompile' do
    logger       = Logger.new($stderr)
    logger.level = Logger::INFO

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
