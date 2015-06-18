
# Recompress all assets with Google's Zopfli compressor

begin
  require 'rake/hooks'
  require 'zopfli-bin'

  def compress_with_zopfli
    logger = Module.const_defined?("Logging".to_sym) ? ::Logging.logger["Assets::Zopfli"] : Rails.logger
    logger.info "running zopfli compressor"

    asset_path = File.join(Rails.root, "public", Rails.application.config.assets.prefix)
    manifest_file = Pathname.glob(File.join(asset_path, ".sprockets-manifest*.json")).first
    manifest = MultiJson.load(File.read(manifest_file))

    manifest["assets"].values.each do |f|
      file = File.join(asset_path, f)
      if File.exist?(file) then
        logger.info "Compressing with zopfli: #{f}"

        if file =~ /\.png$/i then
          Zopfli::Bin.compress_png(file)
        else
          Zopfli::Bin.compress(file, true)
        end

        mtime = File.mtime(file)
        File.utime(mtime, mtime, "#{file}.gz") if File.exists?("#{file}.gz")
      end
    end
  end

  after 'assets:precompile' do
    compress_with_zopfli()
  end

  namespace :assets do
    desc "[re-]compress assets using the zopfli compressor"
    task :zopfli do
      compress_with_zopfli()
    end
  end

rescue LoadError
end
