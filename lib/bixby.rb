
module Bixby
  require "bixby/file_download"
  require "bixby/hooks"
  require "bixby/async"

  class << self
    attr_accessor :ref
  end
end

# set version
rev_file = File.join(Rails.root, "REVISION")
if File.exists? rev_file then
  Bixby.ref = File.read(rev_file).strip
else
  Bixby.ref = "HEAD"
end

require 'bixby/modules'
