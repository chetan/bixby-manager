
begin
  require 'rake/hooks'

  def write_short_filenames
    logger = Module.const_defined?("Logging".to_sym) ? ::Logging.logger["Assets::PreCompile"] : Rails.logger

    env = Rails.application.assets

    asset_path = File.join(Rails.root, "public", Rails.application.config.assets.prefix)
    manifest_file = Sprockets::ManifestUtils.find_directory_manifest(asset_path)
    manifest = Sprockets::Manifest.new(env, asset_path, manifest_file)

    manifest.assets.values.each do |f|
      if f =~ /(\-[a-z0-9]{32,64})/ then
        fn = f.gsub(/(\-[a-z0-9]{32,64})/, '')
        logger.info "Writing #{fn}"
        FileUtils.copy_file(File.join(asset_path, f), File.join(asset_path, fn))
        FileUtils.copy_file(File.join(asset_path, f+".gz"), File.join(asset_path, fn+".gz")) if File.exists?(File.join(asset_path, f+".gz"))
      end
    end
  end

  namespace :assets do
    desc "write short asset filenames"
    task :shorten_filenames do
      write_short_filenames()
    end
  end

rescue LoadError
end
