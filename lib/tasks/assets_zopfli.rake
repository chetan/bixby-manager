
# Recompress gzipped assets with Google's Zopfli compressor

begin
  require 'rake/hooks'
  require 'zopfli-bin'

  after 'assets:precompile' do
    logger = Module.const_defined?("Logging".to_sym) ? ::Logging.logger["Rake::Assets::Zopfli"] : Rails.logger

    env = Sprockets::Environment.new(Rails.root)
    env.append_path File.join(Rails.root, "public", Rails.application.config.assets.prefix)

    asset_path = File.join(Rails.root, "public", Rails.application.config.assets.prefix)
    manifest_file = Pathname.glob(File.join(asset_path, "manifest*.json")).first
    manifest = MultiJson.load(File.read(manifest_file))

    manifest["assets"].values.each do |f|
      file = File.join(asset_path, f)
      if File.exist?(file) && File.exist?(file+".gz") then
        logger.info "Recompressing with zopfli: #{f}"

        Zopfli::Bin.compress(file, true)
        mtime = File.mtime(file)
        File.utime(mtime, mtime, "#{file}.gz")
      end
    end
  end

rescue LoadError => ex
end
