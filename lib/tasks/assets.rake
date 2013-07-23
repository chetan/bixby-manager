
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

    files = Dir.glob(File.join(Rails.root, "public", Rails.application.config.assets.prefix, "**/**"))
    files.each do |f|
      if f =~ /(\-[a-z0-9]{32})/ then
        fn = f.gsub(/(\-[a-z0-9]{32})/, '')
        logger.info "Writing #{fn}"
        FileUtils.copy_file(f, fn)
      end
    end
  end

rescue LoadError => ex
end
