
begin

  require 'yard'

  bixby_common_path = File.join(Bundler.definition.specs["bixby-common"].first.gem_dir, "lib/**/*.rb")

  YARD::Rake::YardocTask.new do |t|
    t.files   = [ 'lib/**/*.rb', 'app/**/*.rb', bixby_common_path ]
    t.options = [ '--output-dir', './yardoc', '-m', 'markdown' ]
  end

rescue LoadError
  warn "yard not available, documentation tasks not provided."
end

