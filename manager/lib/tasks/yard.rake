
require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files   = [ 'lib/**/*.rb', 'app/**/*.rb' ]
  t.options = [ '--output-dir', './yardoc' ]
end

