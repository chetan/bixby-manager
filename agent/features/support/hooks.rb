
require 'fileutils'

Before do
    FileUtils.rm_rf("/tmp/devops/test") if File.exists? "/tmp/devops/test"
end
