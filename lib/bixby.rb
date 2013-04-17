
module Bixby
  require "bixby/file_download"
  require "bixby/hooks"
  require "bixby/async"

  class << self
    attr_accessor :ref, :ref_date
  end
end

# set version
rev_file = File.join(Rails.root, "REVISION")
if File.exists? rev_file then
  Bixby.ref = File.read(rev_file).strip
  Bixby.ref_date = File.mtime(rev_file).to_s
else
  Bixby.ref = "HEAD"
  Bixby.ref_date = "HEAD"
end

require 'bixby/modules'
